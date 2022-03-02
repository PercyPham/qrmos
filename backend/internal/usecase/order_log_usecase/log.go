package order_log_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewOrderLogUsecase(olr repo.OrderLog) *OrderLogUsecase {
	return &OrderLogUsecase{olr}
}

type OrderLogUsecase struct {
	orderLogRepo repo.OrderLog
}

func (u *OrderLogUsecase) LogActionByCus(t time.Time, orderID int, action string, cus *entity.Customer) error {
	log := &entity.OrderLog{
		OrderID: orderID,
		Action:  action,
		Actor: &entity.OrderLogActor{
			Type:       entity.OrderCreatorTypeCustomer,
			CustomerID: cus.ID,
		},
		CreatedAt: t,
	}
	if err := u.orderLogRepo.Create(log); err != nil {
		return apperror.Wrap(err, "repo creates order log")
	}
	return nil
}

func (u *OrderLogUsecase) LogActionByStaff(t time.Time, orderID int, action string, staff *entity.User) error {
	log := &entity.OrderLog{
		OrderID: orderID,
		Action:  action,
		Actor: &entity.OrderLogActor{
			Type:          entity.OrderCreatorTypeStaff,
			StaffUsername: staff.Username,
		},
		CreatedAt: t,
	}
	if err := u.orderLogRepo.Create(log); err != nil {
		return apperror.Wrap(err, "repo creates order log")
	}
	return nil
}

func (u *OrderLogUsecase) GetLogsOfOrder(orderID int) ([]*entity.OrderLog, error) {
	logs, err := u.orderLogRepo.GetAllByOrderID(orderID)
	if err != nil {
		return nil, apperror.Wrapf(err, "repo get all logs of order '%d'", orderID)
	}
	return logs, nil
}
