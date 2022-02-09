package rest

import (
	"log"
	"net/http"
	"qrmos/internal/common/config"
	"qrmos/internal/usecase/repo"
	"strconv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/autotls"
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
		s.runDev()
	} else {
		s.runProd()
	}
}

func (s *server) runDev() {
	s.r.Use(cors.Default())
	s.setupAPIs()
	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}

func (s *server) runProd() {
	s.r.Static("/web/", "./web")
	s.setupAPIs()

	s.r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})
	log.Fatal(autotls.Run(s.r, config.App().Domains...))
}

func isDevMode() bool {
	return config.App().ENV == "dev"
}
