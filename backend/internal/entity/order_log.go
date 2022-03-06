package entity

import "time"

const (
	OrderActionTypeCreate             = "CREATE"
	OrderActionTypeCancel             = "CANCEL"
	OrderActionTypePayViaMoMo         = "PAY_VIA_MOMO"
	OrderActionTypeReceiveCashPayment = "RECEIVE_CASH_PAYMENT"
	OrderActionTypeChangeDestination  = "CHANGE_DESTINATION"
	OrderActionTypeReady              = "READY"
	OrderActionTypeDeliver            = "DELIVER"
	OrderActionTypeFail               = "FAIL"
)

type OrderLog struct {
	OrderID   int            `json:"orderId"`
	Action    string         `json:"action"`
	Actor     *OrderLogActor `json:"actor"`
	Extra     string         `json:"extra,omitempty"`
	CreatedAt time.Time      `json:"createdAt"`
}

type OrderLogActor struct {
	Type          string `json:"type"`
	CustomerID    string `json:"customerId,omitempty"`
	StaffUsername string `json:"staffUsername,omitempty"`
}
