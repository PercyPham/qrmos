package rest

import (
	"qrmos/internal/common/config"
	"qrmos/internal/usecase/repo"
	"strconv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func NewServer(ur repo.UserRepo) *server {
	if !isDevMode() {
		gin.SetMode(gin.ReleaseMode)
	}

	return &server{
		r:        gin.Default(),
		userRepo: ur,
	}
}

type server struct {
	r        *gin.Engine
	userRepo repo.UserRepo
}

func (s *server) Run() {
	if isDevMode() {
		s.r.Use(cors.Default())
	} else {
		s.r.Static("/web/", "./web")
	}

	s.setupAPIs()

	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}

func isDevMode() bool {
	return config.App().ENV == "dev"
}
