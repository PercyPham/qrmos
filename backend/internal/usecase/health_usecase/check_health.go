package health_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewHealthUsecase(db repo.DB) *HealthUsecase {
	return &HealthUsecase{db}
}

type HealthUsecase struct {
	db repo.DB
}

func (u *HealthUsecase) CheckHealth() error {
	if err := u.db.Ping(); err != nil {
		return apperror.Wrap(err, "ping DB")
	}
	return nil
}
