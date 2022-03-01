package controller

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) markOrderAsPaidByCash(c *gin.Context) {
	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	now := time.Now()
	if _, err := s.authCheck.IsStaff(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	cashPaymentUsecase := order_usecase.NewCashPaymentUsecase(s.orderRepo, s.storeConfigRepo)
	if err := cashPaymentUsecase.MarkPaidByCash(now, orderID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as paid by cash"))
		return
	}

	response.Success(c, true)
}

func (s *server) createMoMoPaymentLink(c *gin.Context) {
	now := time.Now()
	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	if cus, err := s.authCheck.IsCustomer(c); err == nil {
		s.createMoMoPaymentLinkAsCus(now, c, orderID, cus)
		return
	}

	if _, err := s.authCheck.IsStaff(now, c); err == nil {
		s.createMoMoPaymentLinkAsStaff(now, c, orderID)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) createMoMoPaymentLinkAsCus(t time.Time, c *gin.Context, orderID int, cus *entity.Customer) {
	momoPaymentUsecase := order_usecase.NewMoMoPaymentUsecase(s.orderRepo, s.storeConfigRepo)
	paymentLink, err := momoPaymentUsecase.CreatePaymentLinkAsCustomer(t, orderID, cus)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase create momo paymentlink as customer"))
		return
	}
	response.Success(c, paymentLink)
}

func (s *server) createMoMoPaymentLinkAsStaff(t time.Time, c *gin.Context, orderID int) {
	momoPaymentUsecase := order_usecase.NewMoMoPaymentUsecase(s.orderRepo, s.storeConfigRepo)
	paymentLink, err := momoPaymentUsecase.CreatePaymentLinkAsStaff(t, orderID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase create momo paymentlink as staff"))
		return
	}
	response.Success(c, paymentLink)
}

func (s *server) handleMoMoIpnCallback(c *gin.Context) {
	printReqInfo(c, "handleMoMoIpnCallback")
	response.Success(c, true)
}

func (s *server) handleMoMoPaymentCallback(c *gin.Context) {
	printReqInfo(c, "handleMoMoPaymentCallback")
	response.Success(c, true)
}

// TODO: this one is for testing MoMo callback. Should be deleted later.
func printReqInfo(c *gin.Context, handlerName string) {
	m := map[string]interface{}{}

	m["requestor"] = c.Request.RemoteAddr
	m["method"] = c.Request.Method
	m["host"] = c.Request.URL.Host
	m["rawPath"] = c.Request.URL.RawPath
	m["path"] = c.Request.URL.Path
	m["queries"] = c.Request.URL.Query()
	if c.Request.Method == http.MethodPost {
		bodyAsByteArray, _ := ioutil.ReadAll(c.Request.Body)
		jsonMapBody := map[string]interface{}{}
		_ = json.Unmarshal(bodyAsByteArray, &jsonMapBody)
		m["body"] = jsonMapBody
	}

	jsonResult, _ := json.Marshal(m)
	fmt.Println(">>>>>>>")
	fmt.Println(string(jsonResult))
	fmt.Println(">>>>>>>")
}
