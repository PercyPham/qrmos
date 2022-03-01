package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase/momo"
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

	if err := order.MarkAsFailed(t, input.FailReason); err != nil {
		return apperror.Wrap(err, "mark order as failed")
	}

	// TODO: MoMo refund is now Access Denied, ask MoMo for help
	if order.Payment.Type == entity.OrderPaymentTypeMoMo {
		if err := u.refundOrderViaMoMo(order, input.FailReason); err != nil {
			return apperror.Wrap(err, "refund order via momo")
		}
	}
	order.Payment.Refund = true
	order.Payment.RefundAt = &t

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}

func (u *FailOrderUsecase) refundOrderViaMoMo(order *entity.Order, failReason string) error {
	return momo.Refund(order.Payment.MoMoPayment.RequestID, failReason, order.Total, order.Payment.MoMoPayment.TransID)
}
