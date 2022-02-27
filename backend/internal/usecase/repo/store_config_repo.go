package repo

import "qrmos/internal/entity"

type StoreConfig interface {
	Upsert(*entity.StoreConfig) error
	GetByKey(key string) *entity.StoreConfig
	Update(*entity.StoreConfig) error
}
