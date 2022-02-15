package user_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewUserUsecase(ur repo.UserRepo) *UserUsecase {
	return &UserUsecase{ur}
}

type UserUsecase struct {
	userRepo repo.UserRepo
}

func (u *UserUsecase) GetUsers() ([]*entity.User, error) {
	users, err := u.userRepo.GetUsers()
	if err != nil {
		return nil, apperror.Wrap(err, "userRepo gets users")
	}
	for _, user := range users {
		user.RemoveSensityInfo()
	}
	return users, nil
}
