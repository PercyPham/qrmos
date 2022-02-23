package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetOrderUsecase(or repo.Order) *GetOrderUsecase {
	return &GetOrderUsecase{or}
}

type GetOrderUsecase struct {
	orderRepo repo.Order
}

func (u *GetOrderUsecase) GetOrderByID(orderID int) (*entity.Order, error) {
	order := u.orderRepo.GetByID(orderID)
	if order == nil {
		return nil, apperror.New("order not found").WithCode(http.StatusNotFound)
	}
	return order, nil
}
