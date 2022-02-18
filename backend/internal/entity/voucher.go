package entity

type Voucher struct {
	Code     string `json:"code" gorm:"primaryKey"`
	Discount int64  `json:"discount"`
	IsUsed   bool   `json:"isUsed"`
}
