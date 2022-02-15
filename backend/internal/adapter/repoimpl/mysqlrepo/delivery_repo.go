package mysqlrepo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"

	"gorm.io/gorm"
)

func NewDeliveryRepo(db *gorm.DB) repo.Delivery {
	return &deliveryRepo{db}
}

type deliveryRepo struct {
	db *gorm.DB
}

func (ur *deliveryRepo) Create(dest *entity.DeliveryDestination) error {
	result := ur.db.Create(dest)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates delivery destination")
	}
	return nil
}

func (ur *deliveryRepo) GetByName(name string) *entity.DeliveryDestination {
	dest := new(entity.DeliveryDestination)
	result := ur.db.Where("name = ?", name).First(dest)
	if result.Error != nil {
		return nil
	}
	return dest
}
