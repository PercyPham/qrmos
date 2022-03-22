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
const OrderStateCancelled = "cancelled"

func IsValidOrderState(state string) bool {
	validStates := map[string]bool{
		OrderStatePending:   true,
		OrderStateConfirmed: true,
		OrderStateReady:     true,
		OrderStateDelivered: true,
		OrderStateFailed:    true,
		OrderStateCancelled: true,
	}
	return validStates[state]
}

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
	OrderItems          []*OrderItem  `json:"orderItems,omitempty"`
	CreatedAt           time.Time     `json:"createdAt"`
}

const OrderPaymentTypeCash = "cash"
const OrderPaymentTypeMoMo = "momo"

type OrderPayment struct {
	Type        string            `json:"type"`
	Success     bool              `json:"success"`
	SuccessAt   *time.Time        `json:"successAt,omitempty"`
	Refund      bool              `json:"refund,omitempty"`
	RefundAt    *time.Time        `json:"refundAt,omitempty"`
	MoMoPayment *OrderMoMoPayment `json:"momoPayment,omitempty"`
}

type OrderMoMoPayment struct {
	RequestID            string     `json:"requestID,omitempty"`
	TransID              int64      `json:"transID,omitempty"`
	PaymentLink          string     `json:"paymentLink,omitempty"`
	PaymentLinkCreatedAt *time.Time `json:"paymentLinkCreatedAt,omitempty"`
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

func (order *Order) Cancel() (hasUpdated bool, err error) {
	if order.State == OrderStateCancelled {
		return false, nil
	}
	if order.State != OrderStatePending {
		return false, apperror.Newf("cannot cancel order with state '%s'", order.State).
			WithCode(http.StatusForbidden)
	}
	order.State = OrderStateCancelled
	return true, nil
}

func (order *Order) MarkAsReady() (hasUpdated bool, err error) {
	if order.State == OrderStateReady {
		return false, nil
	}
	if order.State != OrderStateConfirmed {
		return false, apperror.Newf("cannot mark '%s' order as '%s'", order.State, OrderStateReady).
			WithCode(http.StatusForbidden)
	}
	order.State = OrderStateReady
	return true, nil
}

func (order *Order) MarkAsDelivered() (hasUpdated bool, err error) {
	if order.State == OrderStateDelivered {
		return false, nil
	}
	if order.State != OrderStateReady {
		return false, apperror.Newf("cannot mark '%s' order as '%s'", order.State, OrderStateDelivered).
			WithCode(http.StatusForbidden)
	}
	order.State = OrderStateDelivered
	return true, nil
}

func (order *Order) SetDeliveryDestination(destName string) (hasUpdated bool, err error) {
	if !(order.State == OrderStatePending || order.State == OrderStateConfirmed) {
		return false, apperror.Newf("cannot set new delivery destination when order is in state '%s'", order.State).
			WithCode(http.StatusForbidden)
	}
	if order.DeliveryDestination != destName {
		order.DeliveryDestination = destName
		hasUpdated = true
	}
	return hasUpdated, nil
}

func (order *Order) MarkPaidByCash(t time.Time) error {
	if order.State != OrderStatePending {
		return apperror.Newf("cannot mark '%s' order as paid by cash", order.State)
	}
	order.State = OrderStateConfirmed
	order.Payment = &OrderPayment{
		Type:      OrderPaymentTypeCash,
		Success:   true,
		SuccessAt: &t,
	}
	return nil
}

func (order *Order) MarkPaidByMoMo(t time.Time, momoPaymentReqId string, momoPaymentTransID int64) error {
	if order.State != OrderStatePending {
		return apperror.Newf("cannot mark '%s' order as paid by momo", order.State)
	}
	order.State = OrderStateConfirmed
	order.Payment = &OrderPayment{
		Type:      OrderPaymentTypeMoMo,
		Success:   true,
		SuccessAt: &t,
		MoMoPayment: &OrderMoMoPayment{
			RequestID: momoPaymentReqId,
			TransID:   momoPaymentTransID,
		},
	}
	return nil
}

func (order *Order) MarkAsFailed(t time.Time, failReason string) error {
	if failReason == "" {
		return apperror.New("fail reason must be provided")
	}
	if !(order.State == OrderStateConfirmed ||
		order.State == OrderStateReady ||
		order.State == OrderStateDelivered) {
		return apperror.Newf("cannot mark '%s' order as '%s'", order.State, OrderStateFailed)
	}
	order.State = OrderStateFailed
	order.FailReason = failReason
	return nil
}

func CheckIfOrderUpdatableAt(t time.Time, order *Order, openingHours *StoreConfigOpeningHours) error {
	if !isInSameDate(t, order.CreatedAt) {
		return apperror.New("not in same creation date")
	}
	if !openingHours.IsInOpeningHours(t) {
		return apperror.New("not in opening hours")
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

// GetCachedMoMoPaymentLink returns cached payment link if the link is
// created in less than 5 minutes input time (now).
func (order *Order) GetCachedMoMoPaymentLink(t time.Time) string {
	if order.Payment == nil ||
		order.Payment.Type != OrderPaymentTypeMoMo ||
		order.Payment.MoMoPayment == nil ||
		order.Payment.MoMoPayment.PaymentLinkCreatedAt.Add(5*time.Minute).Before(t) {
		return ""
	}
	return order.Payment.MoMoPayment.PaymentLink
}
