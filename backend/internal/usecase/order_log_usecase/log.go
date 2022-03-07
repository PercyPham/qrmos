package order_log_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"sort"
	"time"
)

func NewOrderLogUsecase(olr repo.OrderLog) *OrderLogUsecase {
	return &OrderLogUsecase{olr}
}

type OrderLogUsecase struct {
	orderLogRepo repo.OrderLog
}

func (u *OrderLogUsecase) LogActionByCus(cus *entity.Customer, t time.Time, orderID int, action, extra string) error {
	log := &entity.OrderLog{
		OrderID: orderID,
		Action:  action,
		Actor: &entity.OrderLogActor{
			Type:       entity.OrderCreatorTypeCustomer,
			CustomerID: cus.ID,
		},
		Extra:     extra,
		CreatedAt: t,
	}
	if err := u.orderLogRepo.Create(log); err != nil {
		return apperror.Wrap(err, "repo creates order log")
	}
	return nil
}

func (u *OrderLogUsecase) LogActionByStaff(staff *entity.User, t time.Time, orderID int, action, extra string) error {
	log := &entity.OrderLog{
		OrderID: orderID,
		Action:  action,
		Actor: &entity.OrderLogActor{
			Type:          entity.OrderCreatorTypeStaff,
			StaffUsername: staff.Username,
		},
		Extra:     extra,
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
	sort.Slice(logs, func(i, j int) bool {
		return logs[i].CreatedAt.Before(logs[j].CreatedAt)
	})
	return logs, nil
}
