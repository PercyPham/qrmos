package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) login(c *gin.Context) {
	body := new(usecase.LoginInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, apperror.Wrap(err, "bind json req body"))
		return
	}

	loginUsecase := usecase.NewLoginUsecase(s.userRepo)
	accessToken, err := loginUsecase.Login(time.Now(), body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase logins user"))
		return
	}

	response.Success(c, accessToken)
}
