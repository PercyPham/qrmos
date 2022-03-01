package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
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

	if err := u.validatePaymentTime(t, order); err != nil {
		return apperror.Wrap(err, "validate payment time")
	}

	if err := order.MarkPaidByCash(t); err != nil {
		return apperror.Wrap(err, "mark order as paid by cash")
	}

	if err := u.orderRepo.Update(order); err != nil {
		return apperror.Wrap(err, "repo updates order")
	}

	return nil
}

func (u *CashPaymentUsecase) validatePaymentTime(t time.Time, order *entity.Order) error {
	openingHours, err := store_cfg_usecase.GetOpeningHoursCfg(u.storeConfigRepo)
	if err != nil {
		return apperror.Wrap(err, "usecase gets store opening hours config")
	}
	if err := entity.CheckIfOrderUpdatableAt(t, order, openingHours); err != nil {
		return apperror.Wrap(err, "check if order is updatable").WithCode(http.StatusBadRequest)
	}
	return nil
}
