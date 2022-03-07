package controller

import (
	"fmt"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) createOrder(c *gin.Context) {
	now := time.Now()

	body := new(order_usecase.CreateOrderInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	if cus, err := s.authCheck.IsCustomer(c); err == nil {
		s.createOrderAsCustomer(c, now, body, cus)
		return
	} else if staff, err := s.authCheck.IsStaff(now, c); err == nil {
		s.createOrderAsStaff(c, now, body, staff)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) createOrderAsCustomer(c *gin.Context, t time.Time, input *order_usecase.CreateOrderInput, cus *entity.Customer) {
	input.CustomerName = cus.FullName
	input.CustomerPhone = cus.PhoneNumber
	input.Creator = &entity.OrderCreator{
		Type:       entity.OrderCreatorTypeCustomer,
		CustomerID: cus.ID,
	}

	createOrderUsecase := order_usecase.NewCreateOrderUsecase(
		s.orderRepo, s.menuRepo, s.deliveryRepo, s.voucherRepo, s.storeConfigRepo)
	order, err := createOrderUsecase.Create(t, input)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates order"))
		return
	}

	s.logOrderActionByCus(cus, t, order.ID, entity.OrderActionTypeCreate, "")

	response.Success(c, order)
}

func (s *server) createOrderAsStaff(c *gin.Context, t time.Time, input *order_usecase.CreateOrderInput, staff *entity.User) {
	input.Creator = &entity.OrderCreator{
		Type:          entity.OrderCreatorTypeStaff,
		StaffUsername: staff.Username,
	}

	createOrderUsecase := order_usecase.NewCreateOrderUsecase(
		s.orderRepo, s.menuRepo, s.deliveryRepo, s.voucherRepo, s.storeConfigRepo)
	order, err := createOrderUsecase.Create(t, input)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates order"))
		return
	}

	s.logOrderActionByStaff(staff, t, order.ID, entity.OrderActionTypeCreate, "")

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

	if staff, err := s.authCheck.IsStaff(time.Now(), c); err == nil {
		s.cancelOrderAsStaff(c, orderID, staff)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) cancelOrderAsCustomer(c *gin.Context, orderID int, cus *entity.Customer) {
	cancelOrderUsecase := order_usecase.NewCancelOrderUsecase(s.orderRepo)
	hasUpdated, err := cancelOrderUsecase.CancelByCustomer(orderID, cus.ID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase cancels order as customer"))
		return
	}
	if hasUpdated {
		s.logOrderActionByCus(cus, time.Now(), orderID, entity.OrderActionTypeCancel, "")
	}
	response.Success(c, true)
}

func (s *server) cancelOrderAsStaff(c *gin.Context, orderID int, staff *entity.User) {
	cancelOrderUsecase := order_usecase.NewCancelOrderUsecase(s.orderRepo)
	hasUpdated, err := cancelOrderUsecase.Cancel(orderID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase cancels order as staff"))
		return
	}
	if hasUpdated {
		s.logOrderActionByStaff(staff, time.Now(), orderID, entity.OrderActionTypeCancel, "")
	}
	response.Success(c, true)
}

func (s *server) markOrderAsReady(c *gin.Context) {
	now := time.Now()

	staff, err := s.authCheck.IsStaff(now, c)
	if err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	progressUsecase := order_usecase.NewProgressUsecase(s.orderRepo)
	hasUpdated, err := progressUsecase.MarkAsReady(orderID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as ready"))
		return
	}

	if hasUpdated {
		s.logOrderActionByStaff(staff, now, orderID, entity.OrderActionTypeReady, "")
	}
	response.Success(c, true)
}

func (s *server) markOrderAsDelivered(c *gin.Context) {
	now := time.Now()

	staff, err := s.authCheck.IsStaff(now, c)
	if err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	progressUsecase := order_usecase.NewProgressUsecase(s.orderRepo)
	hasUpdated, err := progressUsecase.MarkAsDelivered(orderID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as delivered"))
		return
	}

	if hasUpdated {
		s.logOrderActionByStaff(staff, now, orderID, entity.OrderActionTypeDeliver, "")
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
		s.changeOrderDeliveryDestAsCustomer(c, cus, orderID, destName)
		return
	}

	if staff, err := s.authCheck.IsStaff(time.Now(), c); err == nil {
		s.changeOrderDeliveryDestAsStaff(c, staff, orderID, destName)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) changeOrderDeliveryDestAsCustomer(
	c *gin.Context,
	cus *entity.Customer,
	orderID int,
	destName string) {
	changeDestUsecase := order_usecase.NewChangeDeliveryDestUsecase(s.orderRepo, s.deliveryRepo)
	hasUpdated, oldDest, err := changeDestUsecase.ChangeDeliveryDestinationByCustomer(cus.ID, orderID, destName)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase changes order's delivery destination"))
		return
	}
	if hasUpdated {
		s.logOrderActionByCus(
			cus,
			time.Now(),
			orderID,
			entity.OrderActionTypeChangeDestination,
			fmt.Sprintf("from '%s' to '%s'", oldDest, destName))
	}
	response.Success(c, true)
}

func (s *server) changeOrderDeliveryDestAsStaff(
	c *gin.Context,
	staff *entity.User,
	orderID int,
	destName string) {
	changeDestUsecase := order_usecase.NewChangeDeliveryDestUsecase(s.orderRepo, s.deliveryRepo)
	hasUpdated, oldDest, err := changeDestUsecase.ChangeDeliveryDestination(orderID, destName)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase changes order's delivery destination"))
		return
	}
	if hasUpdated {
		s.logOrderActionByStaff(
			staff,
			time.Now(),
			orderID,
			entity.OrderActionTypeChangeDestination,
			fmt.Sprintf("from '%s' to '%s'", oldDest, destName))
	}
	response.Success(c, true)
}

func (s *server) markOrderAsFailed(c *gin.Context) {
	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	now := time.Now()
	manager, err := s.authCheck.IsManager(now, c)
	if err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(order_usecase.FailOrderInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}
	body.OrderID = orderID

	failOrderUsecase := order_usecase.NewFailOrderUsecase(s.orderRepo)
	if err := failOrderUsecase.MarkAsFailed(now, body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase marks order as failed"))
		return
	}

	s.logOrderActionByStaff(manager, now, orderID, entity.OrderActionTypeFail, "")
	response.Success(c, true)
}
