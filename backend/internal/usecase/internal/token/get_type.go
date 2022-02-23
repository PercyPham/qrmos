package token

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"

	"github.com/golang-jwt/jwt"
)

type AccessTokenClaims struct {
	Type string `json:"type"`
	jwt.StandardClaims
}

func GetAccessTokenType(accessToken string) (string, error) {
	token, err := jwt.ParseWithClaims(accessToken, &AccessTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, apperror.Newf(
				"expected signing method '%v', got '%v'",
				jwt.SigningMethodHS256.Name,
				token.Header["alg"])
		}
		return []byte(config.App().Secret), nil
	})
	if err != nil {
		return "", apperror.Wrap(err, "parse token with claims")
	}
	if claims, ok := token.Claims.(*AccessTokenClaims); ok && token.Valid {
		if !(claims.Type == AccessTokenTypeStaff || claims.Type == AccessTokenTypeCustomer) {
			return "", apperror.Newf("unexpected access token type '%s'", claims.Type)
		}
		return claims.Type, nil
	} else {
		return "", apperror.Wrap(err, "parse token")
	}
}
