package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewFailOrderUsecase(or repo.Order) *FailOrderUsecase {
	return &FailOrderUsecase{or}
}

type FailOrderUsecase struct {
	orderRepo repo.Order
}

type FailOrderInput struct {
	OrderID    int
	FailReason string `json:"failReason"`
}

func (i *FailOrderInput) validate() error {
	if i.FailReason == "" {
		return apperror.New("failReason must be provided")
	}
	return nil
}

func (u *FailOrderUsecase) MarkAsFailed(t time.Time, input *FailOrderInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input")
	}

	order := u.orderRepo.GetByID(input.OrderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if err := order.MarkAsFailed(input.FailReason); err != nil {
		return apperror.Wrap(err, "mark order as failed")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}
