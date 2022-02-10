package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase"

	"github.com/gin-gonic/gin"
)

func (s *server) getAllUsers(c *gin.Context) {
	getUsersUsecase := usecase.NewGetUsersUsecase(s.userRepo)

	users, err := getUsersUsecase.GetUsers()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets users"))
		return
	}

	response.Success(c, users)
}
