package entity

import "time"

const (
	OrderActionTypeCreate  = "CREATE"
	OrderActionTypeCancel  = "CANCEL"
	OrderActionTypePay     = "PAY"
	OrderActionTypeReady   = "READY"
	OrderActionTypeDeliver = "DELIVER"
	OrderActionTypeFail    = "FAIL"
)

type OrderLog struct {
	OrderID   int            `json:"orderId"`
	Action    string         `json:"action"`
	Actor     *OrderLogActor `json:"actor"`
	CreatedAt time.Time      `json:"createdAt"`
}

type OrderLogActor struct {
	Type          string `json:"type"`
	CustomerID    string `json:"customerId"`
	StaffUsername string `json:"staffUsername"`
}
