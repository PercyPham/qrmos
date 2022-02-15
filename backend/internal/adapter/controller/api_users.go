package controller

import (
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

	userUsecase := user_usecase.NewGetUsersUsecase(s.userRepo)
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
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	createUserUsecase := user_usecase.NewCreateUserUsecase(s.userRepo)
	if err := createUserUsecase.CreateUser(now, body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates user"))
		return
	}

	response.Success(c, true)
}

func (s *server) updateUser(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsAdmin(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(user_usecase.UpdateUserInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}
	body.Username = c.Param("username")

	updateUserUsecase := user_usecase.NewUpdateUserUsecase(s.userRepo)
	if err := updateUserUsecase.UpdateUser(now, body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase updates user"))
		return
	}

	response.Success(c, true)
}
