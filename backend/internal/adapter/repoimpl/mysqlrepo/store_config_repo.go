package mysqlrepo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func NewStoreConfigRepo(db *gorm.DB) repo.StoreConfig {
	return &storeConfigRepo{db}
}

type storeConfigRepo struct {
	db *gorm.DB
}

func (r *storeConfigRepo) Upsert(cfg *entity.StoreConfig) error {
	result := r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "cfg_key"}},
		DoUpdates: clause.AssignmentColumns([]string{"cfg_val"}),
	}).Create(cfg)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm upsert store config")
	}
	return nil
}

func (r *storeConfigRepo) GetByKey(key string) *entity.StoreConfig {
	cfg := new(entity.StoreConfig)
	result := r.db.Where("cfg_key = ?", key).First(cfg)
	if result.Error != nil {
		return nil
	}
	return cfg
}

func (r *storeConfigRepo) Update(cfg *entity.StoreConfig) error {
	result := r.db.Save(cfg)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm db save store config")
	}
	return nil
}
