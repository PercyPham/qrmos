package repo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
)

type Order interface {
	Create(*entity.Order) error
	// GetOrders returns list of Order info, does not include order items
	GetOrders(*GetOrdersFilter) (orders []*entity.Order, total int, err error)
	GetByID(id int) *entity.Order
	// Update updates order info, it does not update order items
	Update(*entity.Order) error
}

type GetOrdersFilter struct {
	CustomerID  string
	State       string
	Page        int
	ItemPerPage int
}

func (f *GetOrdersFilter) Validate() error {
	if f.Page < 1 {
		return apperror.New("fitler page must be greater than 0")
	}
	if f.ItemPerPage < 1 {
		return apperror.New("fitler itemPerPage must be greater than 0")
	}
	return nil
}
