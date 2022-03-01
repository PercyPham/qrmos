package controller

import (
	"net/http"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/usecase/health_usecase"

	"github.com/gin-gonic/gin"
)

func (s *server) checkHealth(c *gin.Context) {
	healthUsecase := health_usecase.NewHealthUsecase(s.dbRepo)
	if err := healthUsecase.CheckHealth(); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}
	response.Success(c, true)
}
