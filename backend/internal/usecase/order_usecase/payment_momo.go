package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/order_usecase/momo"
	"qrmos/internal/usecase/repo"
	"qrmos/internal/usecase/store_cfg_usecase"
	"time"
)

func NewMoMoPaymentUsecase(or repo.Order, scr repo.StoreConfig) *MoMoPaymentUsecase {
	return &MoMoPaymentUsecase{or, scr}
}

type MoMoPaymentUsecase struct {
	orderRepo       repo.Order
	storeConfigRepo repo.StoreConfig
}

func (u *MoMoPaymentUsecase) CreatePaymentLinkAsCustomer(t time.Time, orderID int, cus *entity.Customer) (string, error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return "", apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	if !(order.Creator != nil &&
		order.Creator.Type == entity.OrderCreatorTypeCustomer &&
		order.Creator.CustomerID == cus.ID) {
		return "", apperror.New("unauthorized").WithCode(http.StatusUnauthorized)
	}

	return u.createPaymentLink(t, order)
}

func (u *MoMoPaymentUsecase) CreatePaymentLinkAsStaff(t time.Time, orderID int) (string, error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return "", apperror.New("order not found").WithCode(http.StatusNotFound)
	}

	return u.createPaymentLink(t, order)
}

func (u *MoMoPaymentUsecase) createPaymentLink(t time.Time, order *entity.Order) (string, error) {
	if err := u.validatePaymentTime(t, order); err != nil {
		return "", apperror.Wrap(err, "validate payment time")
	}

	if order.State != entity.OrderStatePending {
		return "", apperror.Newf("'%s' order cannot have new payment link", order.State)
	}

	cachedPaymentLink := order.GetCachedMoMoPaymentLink(t)
	if cachedPaymentLink != "" {
		return cachedPaymentLink, nil
	}

	paymentLink, err := momo.CreatePaymentLink(order.ID, order.Total)
	if err != nil {
		return "", apperror.Wrap(err, "create momo payment link")
	}

	order.Payment = &entity.OrderPayment{
		Type: entity.OrderPaymentTypeMoMo,
		MoMoPayment: &entity.OrderMoMoPayment{
			PaymentLink:          paymentLink,
			PaymentLinkCreatedAt: &t,
		},
	}
	_ = u.orderRepo.Update(order)

	return paymentLink, nil
}

func (u *MoMoPaymentUsecase) validatePaymentTime(t time.Time, order *entity.Order) error {
	openingHours, err := store_cfg_usecase.GetOpeningHoursCfg(u.storeConfigRepo)
	if err != nil {
		return apperror.Wrap(err, "usecase gets store opening hours config")
	}
	if err := entity.CheckIfOrderUpdatableAt(t, order, openingHours); err != nil {
		return apperror.Wrap(err, "check if order is updatable").WithCode(http.StatusBadRequest)
	}
	return nil
}
