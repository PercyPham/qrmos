package mysqlrepo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"

	"gorm.io/gorm"
)

func NewDBRepo(db *gorm.DB) repo.DB {
	return &dbRepo{db}
}

type dbRepo struct {
	db *gorm.DB
}

func (r *dbRepo) Ping() error {
	sqlDB, err := r.db.DB()
	if err != nil {
		return apperror.Wrap(err, "gorm gets sqlDB")
	}
	if err := sqlDB.Ping(); err != nil {
		return apperror.Wrap(err, "gorm pings db")
	}
	return nil
}
