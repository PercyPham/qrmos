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

func (r *deliveryRepo) Create(dest *entity.DeliveryDestination) error {
	result := r.db.Create(dest)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates delivery destination")
	}
	return nil
}

func (r *deliveryRepo) GetMany() ([]*entity.DeliveryDestination, error) {
	dests := []*entity.DeliveryDestination{}

	result := r.db.Find(&dests)
	if result.Error != nil {
		return nil, apperror.Wrap(result.Error, "gorm db find dests")
	}

	return dests, nil
}

func (r *deliveryRepo) GetByName(name string) *entity.DeliveryDestination {
	dest := new(entity.DeliveryDestination)
	result := r.db.Where("name = ?", name).First(dest)
	if result.Error != nil {
		return nil
	}
	return dest
}

func (r *deliveryRepo) Update(dest *entity.DeliveryDestination) error {
	result := r.db.Save(dest)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm db save delivery destination")
	}
	return nil
}

func (r *deliveryRepo) DeleteByName(name string) error {
	result := r.db.Where("name = ?", name).Delete(entity.DeliveryDestination{})
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm db delete delivery destination '%s'", name)
	}
	return nil
}
