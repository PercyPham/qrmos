package repo

import "qrmos/internal/entity"

type Order interface {
	Create(*entity.Order) error
	GetByID(id int) *entity.Order
}
