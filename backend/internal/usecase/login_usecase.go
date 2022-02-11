package usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewLoginUsecase(ur repo.UserRepo) *LoginUsecase {
	return &LoginUsecase{ur}
}

type LoginUsecase struct {
	userRepo repo.UserRepo
}

func (u *LoginUsecase) Login(t time.Time, username, password string) (resp *LoginResponse, err error) {
	user := u.userRepo.GetUserByUsername(username)
	if user == nil {
		return nil, apperror.New("invalid username or password").WithCode(http.StatusBadRequest)
	}

	if !user.CheckPassword(password) {
		return nil, apperror.New("invalid username or password").WithCode(http.StatusBadRequest)
	}

	if !user.Active {
		return nil, apperror.New("user is not active").WithCode(http.StatusForbidden)
	}

	tokenUsecase := NewTokenUsecase()
	accessToken, err := tokenUsecase.GenStaffAccessToken(t, user)
	if err != nil {
		return nil, apperror.Wrap(err, "generate access token")
	}

	return &LoginResponse{accessToken}, nil
}

type LoginResponse struct {
	AccessToken string `json:"accessToken"`
}
