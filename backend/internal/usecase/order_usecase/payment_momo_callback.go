package order_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase/momo"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewMoMoPaymentCallbackUsecase(or repo.Order) *MoMoPaymentCallbackUsecase {
	return &MoMoPaymentCallbackUsecase{or}
}

type MoMoPaymentCallbackUsecase struct {
	orderRepo repo.Order
}

func (u *MoMoPaymentCallbackUsecase) HandleCallback(t time.Time, data *momo.PaymentCallbackData) error {
	if err := data.Verify(); err != nil {
		return apperror.Wrap(err, "verify momo ipn callback data")
	}
	orderID, err := data.GetQrmosOrderID()
	if err != nil {
		return apperror.Wrap(err, "get order id from ipn callback request data")
	}
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.Wrap(err, "order not found")
	}

	if order.State != entity.OrderStatePending {
		if order.State == entity.OrderStateConfirmed {
			if u.isSameMoMoPaymentRequestID(data.RequestID, order) {
				return nil
			}
			return apperror.Newf("duplicate order payment for order '%d', new momo payment request id is '%s'", order.ID, data.RequestID)
		}
		return apperror.Newf("unexpected payment for '%s' order '%d' with momo payment request id '%s'", order.State, order.ID, data.RequestID)
	}

	if err := order.MarkPaidByMoMo(t, data.RequestID); err != nil {
		return apperror.Wrap(err, "mark order as paid by momo")
	}
	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}
	return nil
}

func (u *MoMoPaymentCallbackUsecase) isSameMoMoPaymentRequestID(reqID string, order *entity.Order) bool {
	if order.Payment != nil &&
		order.Payment.Type == entity.OrderPaymentTypeMoMo &&
		order.Payment.MoMoPayment != nil &&
		order.Payment.MoMoPayment.RequestID == reqID {
		return true
	}
	return false
}
