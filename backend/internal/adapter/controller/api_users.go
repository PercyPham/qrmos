package controller

import (
	"net/http"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/user_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) getAllUsers(c *gin.Context) {
	if err := s.authCheck.IsAdmin(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	userUsecase := user_usecase.NewUserUsecase(s.userRepo)
	users, err := userUsecase.GetUsers()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets users"))
		return
	}

	response.Success(c, users)
}

func (s *server) createUser(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsAdmin(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(user_usecase.CreateUserInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, apperror.Wrap(err, "bind json req body"))
		return
	}

	userUsecase := user_usecase.NewUserUsecase(s.userRepo)
	if err := userUsecase.CreateUser(now, body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates user"))
		return
	}

	response.Success(c, "OK")
}

func newUnauthorizedError(err error) error {
	return apperror.Wrap(err, "authorize").
		WithCode(http.StatusUnauthorized).
		WithPublicMessage("unauthorized")
}
