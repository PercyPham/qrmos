package repo

import "qrmos/internal/entity"

type Order interface {
	Create(*entity.Order) error
	GetByID(id int) *entity.Order
	// Update updates order info, it does not update order items
	Update(*entity.Order) error
}
