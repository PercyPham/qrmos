package usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetUsersUsecase(userRepo repo.UserRepo) *GetUsersUsecase {
	return &GetUsersUsecase{userRepo}
}

type GetUsersUsecase struct {
	userRepo repo.UserRepo
}

func (u *GetUsersUsecase) GetUsers() ([]*entity.User, error) {
	users, err := u.userRepo.GetUsers()
	if err != nil {
		return nil, apperror.Wrap(err, "userRepo gets users")
	}
	return users, nil
}
