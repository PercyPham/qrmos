package repo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
)

type Order interface {
	Create(*entity.Order) error
	GetOrders(*GetOrdersFilter) (orders []*entity.Order, total int, err error)
	GetByID(id int) *entity.Order
	// Update updates order info, it does not update order items
	Update(*entity.Order) error
}

type GetOrdersFilter struct {
	CustomerID    string
	State         string
	Page          int
	ItemPerPage   int
	SortCreatedAt string
	CreatedAtFrom *int64
	CreatedAtTo   *int64
}

func (f *GetOrdersFilter) Validate() error {
	if f.Page < 1 {
		return apperror.New("fitler page must be greater than 0")
	}
	if f.ItemPerPage < 1 {
		return apperror.New("fitler itemPerPage must be greater than 0")
	}
	if f.State != "" {
		if !entity.IsValidOrderState(f.State) {
			return apperror.Newf("invalid state '%s'", f.State)
		}
	}
	if f.SortCreatedAt != "" {
		if !(f.SortCreatedAt == "desc" || f.SortCreatedAt == "asc") {
			return apperror.New("exptected sortCreatedAt be desc or asc")
		}
	}
	return nil
}
