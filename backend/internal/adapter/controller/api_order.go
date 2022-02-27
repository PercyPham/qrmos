package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) createOrder(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsAuthenticated(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(order_usecase.CreateOrderInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	if cus, err := s.authCheck.IsCustomer(c); err == nil {
		body.CustomerName = cus.FullName
		body.CustomerPhone = cus.PhoneNumber
		body.Creator = &entity.OrderCreator{
			Type:       entity.OrderCreatorTypeCustomer,
			CustomerID: cus.ID,
		}
	} else if staff, err := s.authCheck.IsStaff(now, c); err == nil {
		body.Creator = &entity.OrderCreator{
			Type:          entity.OrderCreatorTypeStaff,
			StaffUsername: staff.Username,
		}
	}

	createOrderUsecase := order_usecase.NewCreateOrderUsecase(s.orderRepo, s.menuRepo, s.deliveryRepo, s.voucherRepo)
	order, err := createOrderUsecase.Create(now, body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates order"))
		return
	}

	response.Success(c, order)
}

func (s *server) getOrder(c *gin.Context) {
	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	if cus, err := s.authCheck.IsCustomer(c); err == nil {
		s.getOrderAsCustomer(c, orderID, cus)
		return
	}

	if _, err := s.authCheck.IsStaff(time.Now(), c); err == nil {
		s.getOrderAsStaff(c, orderID)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) getOrderAsCustomer(c *gin.Context, orderID int, cus *entity.Customer) {
	getOrderUsecase := order_usecase.NewGetOrderUsecase(s.orderRepo)
	order, err := getOrderUsecase.GetOrderByID(orderID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets order by id"))
		return
	}
	if order.Creator != nil &&
		order.Creator.Type == entity.OrderCreatorTypeCustomer &&
		order.Creator.CustomerID == cus.ID {
		response.Success(c, order)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthorized")))
}

func (s *server) getOrderAsStaff(c *gin.Context, orderID int) {
	getOrderUsecase := order_usecase.NewGetOrderUsecase(s.orderRepo)
	order, err := getOrderUsecase.GetOrderByID(orderID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets order by id"))
		return
	}
	response.Success(c, order)
}

func (s *server) cancelOrder(c *gin.Context) {
	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	if cus, err := s.authCheck.IsCustomer(c); err == nil {
		s.cancelOrderAsCustomer(c, orderID, cus)
		return
	}

	if _, err := s.authCheck.IsStaff(time.Now(), c); err == nil {
		s.cancelOrderAsStaff(c, orderID)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) cancelOrderAsCustomer(c *gin.Context, orderID int, cus *entity.Customer) {
	cancelOrderUsecase := order_usecase.NewCancelOrderUsecase(s.orderRepo)
	if err := cancelOrderUsecase.CancelByCustomer(orderID, cus.ID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase cancels order as customer"))
		return
	}
	response.Success(c, true)
}

func (s *server) cancelOrderAsStaff(c *gin.Context, orderID int) {
	cancelOrderUsecase := order_usecase.NewCancelOrderUsecase(s.orderRepo)
	if err := cancelOrderUsecase.Cancel(orderID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase cancels order as staff"))
		return
	}
	response.Success(c, true)
}

func (s *server) markOrderAsReady(c *gin.Context) {
	if _, err := s.authCheck.IsStaff(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	progressUsecase := order_usecase.NewProgressUsecase(s.orderRepo)
	if err := progressUsecase.MarkAsReady(orderID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as ready"))
		return
	}

	response.Success(c, true)
}

func (s *server) markOrderAsDelivered(c *gin.Context) {
	if _, err := s.authCheck.IsStaff(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	progressUsecase := order_usecase.NewProgressUsecase(s.orderRepo)
	if err := progressUsecase.MarkAsDelivered(orderID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as delivered"))
		return
	}

	response.Success(c, true)
}

func (s *server) changeOrderDeliveryDest(c *gin.Context) {
	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	destName := c.Param("destName")

	if cus, err := s.authCheck.IsCustomer(c); err == nil {
		s.changeOrderDeliveryDestAsCustomer(c, cus.ID, orderID, destName)
		return
	}

	if _, err := s.authCheck.IsStaff(time.Now(), c); err == nil {
		s.changeOrderDeliveryDestAsStaff(c, orderID, destName)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) changeOrderDeliveryDestAsCustomer(
	c *gin.Context,
	cusID string,
	orderID int,
	destName string) {
	changeDestUsecase := order_usecase.NewChangeDeliveryDestUsecase(s.orderRepo, s.deliveryRepo)
	if err := changeDestUsecase.ChangeDeliveryDestinationByCustomer(cusID, orderID, destName); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase changes order's delivery destination"))
		return
	}
	response.Success(c, true)
}

func (s *server) changeOrderDeliveryDestAsStaff(
	c *gin.Context,
	orderID int,
	destName string) {
	changeDestUsecase := order_usecase.NewChangeDeliveryDestUsecase(s.orderRepo, s.deliveryRepo)
	if err := changeDestUsecase.ChangeDeliveryDestination(orderID, destName); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase changes order's delivery destination"))
		return
	}
	response.Success(c, true)
}

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

	cashPaymentUsecase := order_usecase.NewCashPaymentUsecase(s.orderRepo)
	if err := cashPaymentUsecase.MarkPaidByCash(now, orderID); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as paid by cash"))
		return
	}

	response.Success(c, true)
}
