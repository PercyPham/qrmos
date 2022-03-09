package entity

type DeliveryDestination struct {
	Name         string `json:"name" gorm:"primaryKey"`
	SecurityCode string `json:"securityCode,omitempty"`
}
