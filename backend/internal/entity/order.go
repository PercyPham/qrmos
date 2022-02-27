package entity

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"time"
)

const OrderStatePending = "pending"
const OrderStateConfirmed = "confirmed"
const OrderStateReady = "ready"
const OrderStateDelivered = "delivered"
const OrderStateFailed = "failed"
const OrderStateCanceled = "canceled"

type Order struct {
	ID                  int           `json:"id"`
	State               string        `json:"state"`
	CustomerName        string        `json:"customerName"`
	CustomerPhone       string        `json:"customerPhone"`
	DeliveryDestination string        `json:"deliveryDestination"`
	Voucher             string        `json:"voucher,omitempty"`
	Discount            int64         `json:"discount,omitempty"`
	Total               int64         `json:"total"`
	Payment             *OrderPayment `json:"payment,omitempty"`
	FailReason          string        `json:"failReason,omitempty"`
	Creator             *OrderCreator `json:"creator"`
	OrderItems          []*OrderItem  `json:"orderItems"`
	CreatedAt           time.Time     `json:"createdAt"`
}

const OrderPaymentTypeCash = "cash"
const OrderPaymentTypeMoMo = "momo"

type OrderPayment struct {
	Type     string            `json:"type"`
	Success  bool              `json:"success"`
	Metadata map[string]string `json:"metadata,omitempty"`
}

const OrderCreatorTypeStaff = "staff"
const OrderCreatorTypeCustomer = "customer"

type OrderCreator struct {
	Type          string `json:"type,omitempty"`
	CustomerID    string `json:"customerId,omitempty"`
	StaffUsername string `json:"staffUsername,omitempty"`
}

func (oc *OrderCreator) Validate() error {
	if !(oc.Type == OrderCreatorTypeStaff || oc.Type == OrderCreatorTypeCustomer) {
		return apperror.New("invalid creator type")
	}
	if oc.Type == OrderCreatorTypeCustomer && oc.CustomerID == "" {
		return apperror.New("customer id must be provided when creator type is customer")
	}
	if oc.Type == OrderCreatorTypeStaff && oc.StaffUsername == "" {
		return apperror.New("staff username must be provided when creator type is staff")
	}
	return nil
}

type OrderItem struct {
	Name      string `json:"name"`
	UnitPrice int64  `json:"unitPrice"`
	Quantity  int    `json:"quantity"`
	Note      string `json:"note"`

	/// Options is a map of {optionName : [choice]}
	Options map[string][]string `json:"options"`
}

func (order *Order) Cancel() error {
	if order.State == OrderStateCanceled {
		return nil
	}
	if order.State != OrderStatePending {
		return apperror.Newf("cannot cancel order with state '%s'", order.State).
			WithCode(http.StatusForbidden)
	}
	order.State = OrderStateCanceled
	return nil
}

func (order *Order) MarkAsReady() error {
	if order.State == OrderStateReady {
		return nil
	}
	if order.State != OrderStateConfirmed {
		return apperror.Newf("cannot mark '%s' order as '%s'", order.State, OrderStateReady).
			WithCode(http.StatusForbidden)
	}
	order.State = OrderStateReady
	return nil
}

func (order *Order) MarkAsDelivered() error {
	if order.State == OrderStateDelivered {
		return nil
	}
	if order.State != OrderStateReady {
		return apperror.Newf("cannot mark '%s' order as '%s'", order.State, OrderStateDelivered).
			WithCode(http.StatusForbidden)
	}
	order.State = OrderStateDelivered
	return nil
}

func (order *Order) SetDeliveryDestination(destName string) error {
	if !(order.State == OrderStatePending || order.State == OrderStateConfirmed) {
		return apperror.Newf("cannot set new delivery destination when order is in state '%s'", order.State).
			WithCode(http.StatusForbidden)
	}
	order.DeliveryDestination = destName
	return nil
}

func (order *Order) MarkPaidByCash(t time.Time) error {
	if order.State != OrderStatePending {
		return apperror.Newf("cannot mark '%s' order as paid by cash", order.State)
	}

	if !order.isAtSameCreationDate(t) {
		return apperror.New("cannot mark order created from other date as paid")
	}

	order.Payment = &OrderPayment{
		Type:    OrderPaymentTypeCash,
		Success: true,
	}
	order.State = OrderStateConfirmed
	return nil
}

func (order *Order) isAtSameCreationDate(t time.Time) bool {
	tl := config.App().TimeLocation
	createdAt := order.CreatedAt.In(tl)
	t = t.In(tl)
	if t.Year() != createdAt.Year() ||
		t.Month() != createdAt.Month() ||
		t.Day() != createdAt.Day() {
		return false
	}
	return true
}
