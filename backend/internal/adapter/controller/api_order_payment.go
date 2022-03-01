package controller

import (
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
