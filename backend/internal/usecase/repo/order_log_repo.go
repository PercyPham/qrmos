package repo

import "qrmos/internal/entity"

type OrderLog interface {
	Create(*entity.OrderLog) error
	GetAllByOrderID(orderID int) ([]*entity.OrderLog, error)
}
