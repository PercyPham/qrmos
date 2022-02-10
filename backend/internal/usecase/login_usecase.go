package usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"time"

	"github.com/golang-jwt/jwt"
)

func NewLoginUsecase(ur repo.UserRepo) *LoginUsecase {
	return &LoginUsecase{ur}
}

type LoginUsecase struct {
	userRepo repo.UserRepo
}

func (u *LoginUsecase) Login(username, password string) (resp *LoginResponse, err error) {
	user := u.userRepo.GetUserByUsername(username)
	if user == nil {
		return nil, apperror.New(http.StatusBadRequest, "invalid username or password")
	}

	if !user.CheckPassword(password) {
		return nil, apperror.New(http.StatusBadRequest, "invalid username or password")
	}

	if !user.Active {
		return nil, apperror.New(http.StatusForbidden, "user is not active")
	}

	accessToken, err := u.generateStaffAccessToken(user)
	if err != nil {
		return nil, apperror.Wrap(err, "generate access token")
	}

	return &LoginResponse{accessToken}, nil
}

type LoginResponse struct {
	AccessToken string `json:"accessToken"`
}

func (u *LoginUsecase) generateStaffAccessToken(user *entity.User) (string, error) {
	claims := &StaffAccessTokenClaims{
		Type:     AccessTokenTypeStaff,
		Username: user.Username,
		Role:     user.Role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().UnixNano() + int64(8*time.Hour),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString([]byte(config.App().Secret))
	if err != nil {
		return "", apperror.Wrap(err, "signing token with jwt")
	}

	return signedToken, nil
}

const AccessTokenTypeStaff = "staff"

type StaffAccessTokenClaims struct {
	Type     string `json:"type"`
	Username string `json:"username"`
	Role     string `json:"role"`
	jwt.StandardClaims
}
