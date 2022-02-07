package usecase

import (
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
	return u.userRepo.GetUsers()
}
