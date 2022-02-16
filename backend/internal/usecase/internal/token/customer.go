package token

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/entity"

	"github.com/golang-jwt/jwt"
)

const AccessTokenTypeCustomer = "customer"

type CustomerAccessTokenClaims struct {
	Type        string `json:"type"`
	CustomerID  string `json:"customerId"`
	FullName    string `json:"fullName"`
	PhoneNumber string `json:"phoneNumber"`
	jwt.StandardClaims
}

func GenCustomerAccessToken(customer *entity.Customer) (string, error) {
	claims := &CustomerAccessTokenClaims{
		Type:        AccessTokenTypeCustomer,
		CustomerID:  customer.ID,
		FullName:    customer.FullName,
		PhoneNumber: customer.PhoneNumber,
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString([]byte(config.App().Secret))
	if err != nil {
		return "", apperror.Wrap(err, "signing token with jwt")
	}
	return signedToken, nil
}

func ValidateCustomerAccessTokent(customerAccessToken string) (*CustomerAccessTokenClaims, error) {
	token, err := jwt.ParseWithClaims(customerAccessToken, &CustomerAccessTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, apperror.Newf(
				"expected signing method '%v', got '%v'",
				jwt.SigningMethodHS256.Name,
				token.Header["alg"])
		}
		return []byte(config.App().Secret), nil
	})

	if claims, ok := token.Claims.(*CustomerAccessTokenClaims); ok && token.Valid {
		if claims.Type != AccessTokenTypeCustomer {
			return nil, apperror.New("wrong token type")
		}
		return claims, nil
	} else {
		return nil, apperror.Wrap(err, "parse token")
	}
}
