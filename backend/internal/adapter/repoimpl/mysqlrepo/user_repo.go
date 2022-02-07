package mysqlrepo

import (
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"

	"gorm.io/gorm"
)

func NewUserRepo(db *gorm.DB) repo.UserRepo {
	return &userRepo{db}
}

type userRepo struct {
	db *gorm.DB
}

func (ur *userRepo) GetUsers() ([]*entity.User, error) {
	users := []*entity.User{}

	result := ur.db.Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}

	return users, nil
}
