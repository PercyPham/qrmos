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

func NewAuthCheck(ur repo.User) *AuthCheck {
	return &AuthCheck{ur}
}

type AuthCheck struct {
	userRepo repo.User
}

func (ac *AuthCheck) IsAdmin(t time.Time, c *gin.Context) error {
	return ac.isStaffRole(t, c, entity.UserRoleAdmin)
}

func (ac *AuthCheck) IsManager(t time.Time, c *gin.Context) error {
	return ac.isStaffRole(t, c, entity.UserRoleManager)
}

// IsAuthenticated checks if the user is either customer or staff
func (ac *AuthCheck) IsAuthenticated(t time.Time, c *gin.Context) error {
	accessToken, err := extractAccessToken(c)
	if err != nil {
		return apperror.Wrap(err, "extract access token")
	}
	authUsecase := auth_usecase.NewAuthUsecase(ac.userRepo)
	if err := authUsecase.IsAuthenticated(t, accessToken); err != nil {
		return apperror.Wrap(err, "usecase authenticates user")
	}
	return nil
}

func (ac *AuthCheck) isStaffRole(t time.Time, c *gin.Context, role string) error {
	staff, err := ac.IsStaff(t, c)
	if err != nil {
		return err
	}
	if staff.Role != role {
		return apperror.Newf(
			"expected role '%v', got '%v'",
			role,
			staff.Role)
	}
	return nil
}

func (ac *AuthCheck) IsStaff(t time.Time, c *gin.Context) (*entity.User, error) {
	accessToken, err := extractAccessToken(c)
	if err != nil {
		return nil, apperror.Wrap(err, "extract access token")
	}
	authUsecase := auth_usecase.NewAuthUsecase(ac.userRepo)
	user, err := authUsecase.AuthenticateStaff(t, accessToken)
	if err != nil {
		return nil, apperror.Wrap(err, "authenticate staff")
	}
	return user, nil
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
