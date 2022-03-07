package user_usecase

import (
	"net/http"
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

func (u *GetUsersUsecase) GetUserByUsername(username string) (*entity.User, error) {
	user := u.userRepo.GetByUsername(username)
	if user == nil {
		return nil, apperror.New("user not found").WithCode(http.StatusNotFound)
	}
	user.RemoveSensityInfo()
	return user, nil
}
