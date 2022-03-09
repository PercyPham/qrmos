package delivery_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetDeliveryDestUsecase(dr repo.Delivery) *GetDeliveryDestUsecase {
	return &GetDeliveryDestUsecase{dr}
}

type GetDeliveryDestUsecase struct {
	deliveryRepo repo.Delivery
}

func (u *GetDeliveryDestUsecase) GetDeliveryDestByName(destName string) (*entity.DeliveryDestination, error) {
	dest := u.deliveryRepo.GetByName(destName)
	if dest == nil {
		return nil, apperror.New("delivery destination not found")
	}
	return dest, nil
}

func (u *GetDeliveryDestUsecase) GetDeliveryDestionations() ([]*entity.DeliveryDestination, error) {
	dests, err := u.deliveryRepo.GetMany()
	if err != nil {
		return nil, apperror.Wrap(err, "userRepo gets delivery destinations")
	}
	return dests, nil
}

func (u *GetDeliveryDestUsecase) GetDeliveryDestionationsAsCustomer() ([]*entity.DeliveryDestination, error) {
	dests, err := u.deliveryRepo.GetMany()
	if err != nil {
		return nil, apperror.Wrap(err, "userRepo gets delivery destinations")
	}
	for _, dest := range dests {
		dest.SecurityCode = ""
	}
	return dests, nil
}
