package usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/entity"
	"time"

	"github.com/golang-jwt/jwt"
)

const AccessTokenTypeStaff = "staff"

type StaffAccessTokenClaims struct {
	Type     string `json:"type"`
	Username string `json:"username"`
	Role     string `json:"role"`
	jwt.StandardClaims
}

func NewTokenUsecase() *TokenUsecase {
	return &TokenUsecase{}
}

type TokenUsecase struct {
}

func (u *TokenUsecase) GenStaffAccessToken(t time.Time, user *entity.User) (string, error) {
	claims := &StaffAccessTokenClaims{
		Type:     AccessTokenTypeStaff,
		Username: user.Username,
		Role:     user.Role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: t.UnixNano() + int64(8*time.Hour),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString([]byte(config.App().Secret))
	if err != nil {
		return "", apperror.Wrap(err, "signing token with jwt")
	}

	return signedToken, nil
}
