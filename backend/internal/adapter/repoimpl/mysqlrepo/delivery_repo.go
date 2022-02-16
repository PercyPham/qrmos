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

func (dr *deliveryRepo) Create(dest *entity.DeliveryDestination) error {
	result := dr.db.Create(dest)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates delivery destination")
	}
	return nil
}

func (dr *deliveryRepo) GetByName(name string) *entity.DeliveryDestination {
	dest := new(entity.DeliveryDestination)
	result := dr.db.Where("name = ?", name).First(dest)
	if result.Error != nil {
		return nil
	}
	return dest
}

func (dr *deliveryRepo) Update(dest *entity.DeliveryDestination) error {
	result := dr.db.Save(dest)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm db save delivery destination")
	}
	return nil
}

func (dr *deliveryRepo) DeleteByName(name string) error {
	result := dr.db.Where("name = ?", name).Delete(entity.DeliveryDestination{})
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm db delete delivery destination '%s'", name)
	}
	return nil
}
