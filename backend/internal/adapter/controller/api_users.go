package controller

import (
	"qrmos/internal/usecase"

	"github.com/gin-gonic/gin"
)

func (s *server) getAllUsers(c *gin.Context) {
	getUsersUsecase := usecase.NewGetUsersUsecase(s.userRepo)

	users, err := getUsersUsecase.GetUsers()
	if err != nil {
		c.JSON(500, err.Error())
	}

	c.JSON(200, users)
}
