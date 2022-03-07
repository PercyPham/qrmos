package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewProgressUsecase(or repo.Order) *ProgressUsecase {
	return &ProgressUsecase{or}
}

type ProgressUsecase struct {
	orderRepo repo.Order
}

func (u *ProgressUsecase) MarkAsReady(orderID int) (hasUpdated bool, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return false, apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	hasUpdated, err = order.MarkAsReady()
	if err != nil {
		return false, apperror.Wrap(err, "marks order as ready")
	}

	if hasUpdated {
		if err := u.orderRepo.Update(order); err != nil {
			return false, apperror.Wrap(err, "repo updates order")
		}
	}

	return hasUpdated, nil
}

func (u *ProgressUsecase) MarkAsDelivered(orderID int) (hasUpdated bool, err error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return false, apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	hasUpdated, err = order.MarkAsDelivered()
	if err != nil {
		return false, apperror.Wrap(err, "marks order as delivered")
	}

	if hasUpdated {
		if err := u.orderRepo.Update(order); err != nil {
			return false, apperror.Wrap(err, "repo updates order")
		}
	}

	return hasUpdated, nil
}
