package user_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetUsersUsecase(ur repo.User) *GetUsersUsecase {
	return &GetUsersUsecase{ur}
}

type GetUsersUsecase struct {
	userRepo repo.User
}

func (u *GetUsersUsecase) GetUsers() ([]*entity.User, error) {
	users, err := u.userRepo.GetMany()
	if err != nil {
		return nil, apperror.Wrap(err, "userRepo gets users")
	}
	for _, user := range users {
		user.RemoveSensityInfo()
	}
	return users, nil
}
