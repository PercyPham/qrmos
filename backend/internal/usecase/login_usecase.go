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

type LoginInput struct {
	Username string `json:"username,omitempty"`
	Password string `json:"password,omitempty"`
}

func (i *LoginInput) validate() error {
	if i.Username == "" {
		return apperror.New("username must be provided")
	}
	if i.Password == "" {
		return apperror.New("password must be provided")
	}
	return nil
}

func (u *LoginUsecase) Login(t time.Time, input *LoginInput) (resp *LoginResponse, err error) {
	if err := input.validate(); err != nil {
		return nil, apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	user := u.userRepo.GetUserByUsername(input.Username)
	if user == nil {
		return nil, apperror.Newf("username '%v' not found", input.Username).
			WithCode(http.StatusBadRequest).
			WithPublicMessage("invalid username or password")
	}

	if !user.CheckPassword(input.Password) {
		return nil, apperror.New("invalid password").
			WithCode(http.StatusBadRequest).
			WithPublicMessage("invalid username or password")
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
