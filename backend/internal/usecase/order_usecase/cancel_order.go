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

func (u *CancelOrderUsecase) CancelByCustomer(orderID int, cusID string) error {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if !(order.Creator != nil &&
		order.Creator.Type == entity.OrderCreatorTypeCustomer &&
		order.Creator.CustomerID == cusID) {
		return apperror.New("unauthorized").WithCode(http.StatusUnauthorized)
	}

	if err := order.Cancel(); err != nil {
		return apperror.Wrap(err, "cancel order")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}

func (u *CancelOrderUsecase) Cancel(orderID int) error {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if err := order.Cancel(); err != nil {
		return apperror.Wrap(err, "cancel order")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}
