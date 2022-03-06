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

func (u *ChangeDeliveryDestUsecase) ChangeDeliveryDestinationByCustomer(cusID string, orderID int, destName string) (hasUpdated bool, oldDest string, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return false, "", apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if !(order.Creator != nil &&
		order.Creator.Type == entity.OrderCreatorTypeCustomer &&
		order.Creator.CustomerID == cusID) {
		return false, "", apperror.New("invalid creator").WithCode(http.StatusForbidden)
	}

	return u.changeDeliveryDest(order, destName)
}

func (u *ChangeDeliveryDestUsecase) ChangeDeliveryDestination(orderID int, destName string) (hasUpdated bool, oldDest string, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return false, "", apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	return u.changeDeliveryDest(order, destName)
}

func (u *ChangeDeliveryDestUsecase) changeDeliveryDest(order *entity.Order, destName string) (hasUpdated bool, oldDest string, err error) {
	oldDest = order.DeliveryDestination

	dest := u.deliveryRepo.GetByName(destName)
	if dest == nil {
		return false, "", apperror.New("delivery destination not found").WithCode(http.StatusNotFound)
	}

	hasUpdated, err = order.SetDeliveryDestination(destName)
	if err != nil {
		return false, "", apperror.Wrap(err, "order sets new delivery destination")
	}

	if hasUpdated {
		if err := u.orderRepo.Update(order); err != nil {
			return false, "", apperror.Wrap(err, "repo updates order")
		}
	}

	return hasUpdated, oldDest, nil
}
