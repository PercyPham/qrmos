package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase"
	"qrmos/internal/usecase/order_usecase/momo"
	"strconv"
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
	staff, err := s.authCheck.IsStaff(now, c)
	if err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	cashPaymentUsecase := order_usecase.NewCashPaymentUsecase(s.orderRepo, s.storeConfigRepo)
	if err := cashPaymentUsecase.MarkPaidByCash(now, orderID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as paid by cash"))
		return
	}

	s.logOrderActionByStaff(now, orderID, entity.OrderActionTypeReceiveCashPayment, staff)
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
	body := new(momo.PaymentCallbackData)
	if err := c.ShouldBindJSON(body); err != nil {
		// TODO: special log for MoMo related apis
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}
	momoPaymentCallbackUsecase := order_usecase.NewMoMoPaymentCallbackUsecase(s.orderRepo)
	order, err := momoPaymentCallbackUsecase.HandleCallback(time.Now(), body)
	if err != nil {
		// TODO: special log for MoMo related apis
		response.Error(c, apperror.Wrap(err, "usecase handle momo ipn callback"))
		return
	}
	s.logOrderMoMoPayActionByCus(order)
	response.Success(c, true)
}

func (s *server) handleMoMoPaymentCallback(c *gin.Context) {
	data := getMoMoPaymentCallbackFromQueries(c)
	momoPaymentCallbackUsecase := order_usecase.NewMoMoPaymentCallbackUsecase(s.orderRepo)
	order, err := momoPaymentCallbackUsecase.HandleCallback(time.Now(), data)
	if err != nil {
		// TODO: special log for MoMo related apis
		response.Error(c, apperror.Wrap(err, "usecase handle momo website callback"))
		return
	}
	s.logOrderMoMoPayActionByCus(order)
	// TODO: redirect to Order Success page on front-end
	response.Success(c, true)
}

func (s *server) logOrderMoMoPayActionByCus(order *entity.Order) {
	s.logOrderActionByCus(
		*order.Payment.SuccessAt,
		order.ID,
		entity.OrderActionTypePayViaMoMo,
		&entity.Customer{ID: "unknown"},
	)
}

func getMoMoPaymentCallbackFromQueries(c *gin.Context) *momo.PaymentCallbackData {
	data := &momo.PaymentCallbackData{
		Amount:       getQueryInt64(c, "amount"),
		ExtraData:    c.Query("extraData"),
		Message:      c.Query("message"),
		OrderID:      c.Query("orderId"),
		OrderInfo:    c.Query("orderInfo"),
		OrderType:    c.Query("orderType"),
		PartnerCode:  c.Query("partnerCode"),
		PayType:      c.Query("payType"),
		RequestID:    c.Query("requestId"),
		ResponseTime: getQueryInt64(c, "responseTime"),
		ResultCode:   getQueryInt64(c, "resultCode"),
		Signature:    c.Query("signature"),
		TransID:      getQueryInt64(c, "transId"),
	}
	return data
}

func getQueryInt64(c *gin.Context, name string) int64 {
	val := c.Query(name)
	if val == "" {
		return 0
	}
	num, _ := strconv.ParseInt(val, 10, 64)
	return num
}
