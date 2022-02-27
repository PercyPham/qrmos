package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewCashPaymentUsecase(or repo.Order) *CashPaymentUsecase {
	return &CashPaymentUsecase{or}
}

type CashPaymentUsecase struct {
	orderRepo repo.Order
}

func (u *CashPaymentUsecase) MarkPaidByCash(t time.Time, orderID int) error {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if err := order.MarkPaidByCash(t); err != nil {
		return apperror.Wrap(err, "mark order as paid by cash")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}
