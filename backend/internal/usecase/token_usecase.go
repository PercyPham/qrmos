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

func (u *TokenUsecase) ValidateStaffAccessToken(t time.Time, staffAccessToken string) (*StaffAccessTokenClaims, error) {
	token, err := jwt.ParseWithClaims(staffAccessToken, &StaffAccessTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, apperror.Newf(
				"expected signing method '%v', got '%v'",
				jwt.SigningMethodHS256.Name,
				token.Header["alg"])
		}
		return []byte(config.App().Secret), nil
	})

	if claims, ok := token.Claims.(*StaffAccessTokenClaims); ok && token.Valid {
		return claims, nil
	} else {
		return nil, apperror.Wrap(err, "parse token")
	}
}
