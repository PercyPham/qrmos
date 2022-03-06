package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewCancelOrderUsecase(or repo.Order) *CancelOrderUsecase {
	return &CancelOrderUsecase{or}
}

type CancelOrderUsecase struct {
	orderRepo repo.Order
}

func (u *CancelOrderUsecase) CancelByCustomer(orderID int, cusID string) (hasUpdated bool, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return false, apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if !(order.Creator != nil &&
		order.Creator.Type == entity.OrderCreatorTypeCustomer &&
		order.Creator.CustomerID == cusID) {
		return false, apperror.New("unauthorized").WithCode(http.StatusUnauthorized)
	}

	hasUpdated, err = order.Cancel()
	if err != nil {
		return false, apperror.Wrap(err, "cancel order")
	}

	if hasUpdated {
		if err := u.orderRepo.Update(order); err != nil {
			return false, apperror.Wrap(err, "repo updates order")
		}
	}

	return hasUpdated, nil
}

func (u *CancelOrderUsecase) Cancel(orderID int) (hasUpdated bool, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return false, apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	hasUpdated, err = order.Cancel()
	if err != nil {
		return false, apperror.Wrap(err, "cancel order")
	}

	if hasUpdated {
		if err := u.orderRepo.Update(order); err != nil {
			return false, apperror.Wrap(err, "repo updates order")
		}
	}

	return hasUpdated, nil
}
