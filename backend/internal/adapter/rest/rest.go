package rest

import (
	"qrmos/internal/common/config"
	"qrmos/internal/usecase/repo"
	"strconv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func NewServer(ur repo.UserRepo) *server {
	isDevMode := config.App().ENV == "dev"
	if !isDevMode {
		gin.SetMode(gin.ReleaseMode)
	}

	return &server{
		r:        gin.Default(),
		userRepo: ur,
	}
}

type server struct {
	r *gin.Engine

	userRepo repo.UserRepo
}

func (s *server) Run() {
	isDevMode := config.App().ENV == "dev"

	if isDevMode {
		s.r.Use(cors.Default())
	}

	api := s.r.Group("/api")

	api.GET("/health", s.checkHealth)
	api.GET("/users", s.getAllUsers)

	if !isDevMode {
		s.r.Static("/web/", "./web")
	}

	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}
