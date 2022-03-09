package repo

import "qrmos/internal/entity"

type Delivery interface {
	Create(*entity.DeliveryDestination) error
	GetMany() ([]*entity.DeliveryDestination, error)
	GetByName(name string) *entity.DeliveryDestination
	Update(*entity.DeliveryDestination) error
	DeleteByName(name string) error
}
