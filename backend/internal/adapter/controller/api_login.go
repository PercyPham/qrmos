package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/auth_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) login(c *gin.Context) {
	body := new(auth_usecase.LoginInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	loginUsecase := auth_usecase.NewLoginUsecase(s.userRepo)
	staffAccessToken, err := loginUsecase.Login(time.Now(), body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase logins user"))
		return
	}

	response.Success(c, gin.H{
		"accessToken": staffAccessToken,
	})
}
