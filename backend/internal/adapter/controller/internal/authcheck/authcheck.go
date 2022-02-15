package authcheck

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/auth_usecase"
	"qrmos/internal/usecase/repo"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

func NewAuthCheck(ur repo.UserRepo) *AuthCheck {
	return &AuthCheck{ur}
}

type AuthCheck struct {
	userRepo repo.UserRepo
}

func (ac *AuthCheck) IsAdmin(t time.Time, c *gin.Context) error {
	accessToken, err := extractAccessToken(c)
	if err != nil {
		return apperror.Wrap(err, "extract access token")
	}
	authUsecase := auth_usecase.NewAuthUsecase(ac.userRepo)
	user, err := authUsecase.AuthenticateStaff(t, accessToken)
	if err != nil {
		return apperror.Wrap(err, "authenticate staff")
	}
	if user.Role != entity.UserRoleAdmin {
		return apperror.Newf(
			"expected role '%v', got '%v'",
			entity.UserRoleAdmin,
			user.Role)
	}
	return nil
}

func (ac *AuthCheck) IsCustomer(c *gin.Context) (*entity.Customer, error) {
	accessToken, err := extractAccessToken(c)
	if err != nil {
		return nil, apperror.Wrap(err, "extract access token")
	}
	authUsecase := auth_usecase.NewAuthUsecase(ac.userRepo)
	customer, err := authUsecase.AuthenticateCustomer(accessToken)
	if err != nil {
		return nil, apperror.Wrap(err, "authenticate customer")
	}
	return customer, nil
}

func extractAccessToken(c *gin.Context) (string, error) {
	bearerToken := c.Request.Header.Get("Authorization")
	if bearerToken == "" {
		return "", apperror.New("empty bearer token")
	}
	bearerTokenParts := strings.Split(bearerToken, " ")
	if len(bearerTokenParts) != 2 || bearerTokenParts[0] != "Bearer" {
		return "", apperror.New("invalid bearer token")
	}
	return bearerTokenParts[1], nil
}
