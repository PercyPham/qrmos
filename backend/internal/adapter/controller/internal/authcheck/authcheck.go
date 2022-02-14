package authcheck

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

func IsAdmin(t time.Time, c *gin.Context) error {
	staffAccessToken, err := extractStaffAccessToken(t, c)
	if err != nil {
		return apperror.Wrap(err, "extract staff access token")
	}
	if staffAccessToken.Role != entity.UserRoleAdmin {
		return apperror.Newf(
			"expected role '%v', got '%v'",
			entity.UserRoleAdmin,
			staffAccessToken.Role)
	}
	return nil
}

func extractStaffAccessToken(t time.Time, c *gin.Context) (*usecase.StaffAccessTokenClaims, error) {
	accessToken, err := extractAccessToken(c)
	if err != nil {
		return nil, apperror.Wrap(err, "extract access token")
	}
	staffAccessToken, err := usecase.
		NewTokenUsecase().
		ValidateStaffAccessToken(t, accessToken)
	if err != nil {
		return nil, apperror.Wrap(err, "validate staff access token")
	}
	return staffAccessToken, nil
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
