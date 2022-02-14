package controller

import (
	"qrmos/internal/adapter/controller/internal/response"

	"github.com/gin-gonic/gin"
)

func (s *server) checkHealth(c *gin.Context) {
	// TODO: check DB connection
	response.Success(c, "OK")
}
