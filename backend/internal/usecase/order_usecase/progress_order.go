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

func (u *ProgressUsecase) MarkAsReady(orderID int) error {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if err := order.MarkAsReady(); err != nil {
		return apperror.Wrap(err, "marks order as ready")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}

func (u *ProgressUsecase) MarkAsDelivered(orderID int) error {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if err := order.MarkAsDelivered(); err != nil {
		return apperror.Wrap(err, "marks order as delivered")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}
