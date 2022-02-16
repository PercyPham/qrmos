package token

import (
	"fmt"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/common/security"
	"qrmos/internal/entity"
	"time"

	"github.com/golang-jwt/jwt"
)

const AccessTokenTypeStaff = "staff"

type StaffAccessTokenClaims struct {
	Type     string `json:"type"`
	Username string `json:"username"`
	Key      string `json:"key"`
	jwt.StandardClaims
}

func GenStaffAccessToken(t time.Time, user *entity.User) (string, error) {
	claims := &StaffAccessTokenClaims{
		Type:     AccessTokenTypeStaff,
		Username: user.Username,
		Key:      genStaffTokenKey(t, user.Password),
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

func genStaffTokenKey(t time.Time, password string) string {
	salt := security.GenRanStr(t, 10)
	rawKey := security.HashHS256(password+salt, config.App().Secret)
	key := salt + rawKey
	return key
}

func CheckStaffTokenKey(key, password string) bool {
	if len(key) < 10 {
		return false
	}
	salt := fmt.Sprint(key[:10])
	return key == salt+security.HashHS256(password+salt, config.App().Secret)
}

func ValidateStaffAccessToken(t time.Time, staffAccessToken string) (*StaffAccessTokenClaims, error) {
	token, err := jwt.ParseWithClaims(staffAccessToken, &StaffAccessTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, apperror.Newf(
				"expected signing method '%v', got '%v'",
				jwt.SigningMethodHS256.Name,
				token.Header["alg"])
		}
		return []byte(config.App().Secret), nil
	})
	if err != nil {
		return nil, apperror.Wrap(err, "parse token with claims")
	}

	if claims, ok := token.Claims.(*StaffAccessTokenClaims); ok && token.Valid {
		if claims.Type != AccessTokenTypeStaff {
			return nil, apperror.New("wrong token type")
		}
		return claims, nil
	} else {
		return nil, apperror.Wrap(err, "parse token")
	}
}
