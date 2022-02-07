package rest

import (
	"qrmos/internal/usecase/repo"
	"strconv"

	"github.com/gin-gonic/gin"
)

func NewServer(ur repo.UserRepo) *server {
	return &server{
		r:        gin.Default(),
		userRepo: ur,
	}
}

type server struct {
	r *gin.Engine

	userRepo repo.UserRepo
}

func (s *server) Run(port int) {
	api := s.r.Group("/api")

	api.GET("/health", s.checkHealth)

	api.GET("/users", s.getAllUsers)

	s.r.Run(":" + strconv.Itoa(port))
}
