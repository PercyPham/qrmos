package rest

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

func NewServer() *server {
	return &server{
		r: gin.Default(),
	}
}

type server struct {
	r *gin.Engine
}

func (s *server) Run(port int) {
	api := s.r.Group("/api")

	api.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "OK",
		})
	})

	s.r.Run(":" + strconv.Itoa(port))
}
