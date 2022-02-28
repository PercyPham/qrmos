package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"qrmos/internal/usecase/store_cfg_usecase"
	"time"
)

func NewCashPaymentUsecase(or repo.Order, scr repo.StoreConfig) *CashPaymentUsecase {
	return &CashPaymentUsecase{or, scr}
}

type CashPaymentUsecase struct {
	orderRepo       repo.Order
	storeConfigRepo repo.StoreConfig
}

func (u *CashPaymentUsecase) MarkPaidByCash(t time.Time, orderID int) error {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if err := u.validateTime(t, order); err != nil {
		return apperror.Wrap(err, "validate time")
	}

	if err := order.MarkPaidByCash(); err != nil {
		return apperror.Wrap(err, "mark order as paid by cash")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}

func (u *CashPaymentUsecase) validateTime(t time.Time, order *entity.Order) error {
	if !isInSameDate(t, order.CreatedAt) {
		return apperror.New("not in the same creation date").WithCode(http.StatusForbidden)
	}
	if err := store_cfg_usecase.CheckIsInOpeningHours(t, u.storeConfigRepo); err != nil {
		return apperror.Wrap(err, "check is in opening hours")
	}
	return nil
}

func isInSameDate(t1, t2 time.Time) bool {
	tl := config.App().TimeLocation
	t1 = t1.In(tl)
	t2 = t2.In(tl)
	if t1.Year() != t2.Year() || t1.Month() != t2.Month() || t1.Day() != t2.Day() {
		return false
	}
	return true
}
