package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewChangeDeliveryDestUsecase(or repo.Order, dr repo.Delivery) *ChangeDeliveryDestUsecase {
	return &ChangeDeliveryDestUsecase{or, dr}
}

type ChangeDeliveryDestUsecase struct {
	orderRepo    repo.Order
	deliveryRepo repo.Delivery
}

func (u *ChangeDeliveryDestUsecase) ChangeDeliveryDestinationByCustomer(cusID string, orderID int, destName string) (oldDest string, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return "", apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if !(order.Creator != nil &&
		order.Creator.Type == entity.OrderCreatorTypeCustomer &&
		order.Creator.CustomerID == cusID) {
		return "", apperror.New("invalid creator").WithCode(http.StatusForbidden)
	}
	oldDest = order.DeliveryDestination

	return oldDest, u.changeDeliveryDest(order, destName)
}

func (u *ChangeDeliveryDestUsecase) ChangeDeliveryDestination(orderID int, destName string) (oldDest string, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return "", apperror.New("order not found").WithCode(http.StatusNotFound)
	}
	oldDest = order.DeliveryDestination

	return oldDest, u.changeDeliveryDest(order, destName)
}

func (u *ChangeDeliveryDestUsecase) changeDeliveryDest(order *entity.Order, destName string) error {
	dest := u.deliveryRepo.GetByName(destName)
	if dest == nil {
		return apperror.New("delivery destination not found").WithCode(http.StatusNotFound)
	}

	if err := order.SetDeliveryDestination(destName); err != nil {
		return apperror.Wrap(err, "order sets new delivery destination")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}
