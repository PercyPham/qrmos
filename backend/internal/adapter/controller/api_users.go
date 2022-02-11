package controller

import (
	"net/http"
	"qrmos/internal/adapter/controller/internal/authcheck"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) getAllUsers(c *gin.Context) {
	if err := authcheck.IsAdmin(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	getUsersUsecase := usecase.NewGetUsersUsecase(s.userRepo)
	users, err := getUsersUsecase.GetUsers()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets users"))
		return
	}

	response.Success(c, users)
}

func newUnauthorizedError(err error) error {
	return apperror.Wrap(err, "authorize").
		WithCode(http.StatusUnauthorized).
		WithPublicMessage("unauthorized")
}
