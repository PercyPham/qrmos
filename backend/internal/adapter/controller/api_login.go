package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase"

	"github.com/gin-gonic/gin"
)

func (s *server) login(c *gin.Context) {
	var body struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		response.Error(c, apperror.Wrap(err, "bind json req body"))
		return
	}

	loginUsecase := usecase.NewLoginUsecase(s.userRepo)
	accessToken, err := loginUsecase.Login(body.Username, body.Password)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets users"))
		return
	}

	response.Success(c, accessToken)
}
