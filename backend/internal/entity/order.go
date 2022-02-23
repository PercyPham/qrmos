package entity

import (
	"qrmos/internal/common/apperror"
	"time"
)

const OrderStatePending = "pending"
const OrderStateConfirmed = "confirmed"
const OrderStateReady = "ready"
const OrderStateDelivered = "delivered"
const OrderStateFailed = "failed"
const OrderStateCancelled = "cancelled"

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

type OrderPayment struct {
	Type     string            `json:"type"`
	Success  bool              `json:"success"`
	Metadata map[string]string `json:"metadata"`
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
	if order.State == OrderStateCancelled {
		return nil
	}
	if order.State != OrderStatePending {
		return apperror.Newf("cannot cancel order with state '%s'", order.State)
	}
	order.State = OrderStateCancelled
	return nil
}
