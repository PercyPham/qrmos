package repo

import "qrmos/internal/entity"

type Delivery interface {
	Create(*entity.DeliveryDestination) error
	GetByName(name string) *entity.DeliveryDestination
}
