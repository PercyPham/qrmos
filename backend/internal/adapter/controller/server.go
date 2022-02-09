package controller

import (
	"log"
	"net/http"
	"qrmos/internal/common/config"
	"qrmos/internal/usecase/repo"
	"strconv"
	"strings"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/autotls"
	"github.com/gin-gonic/gin"
)

func NewServer(ur repo.UserRepo) *server {
	if config.App().ENV != "dev" {
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
	switch config.App().ENV {
	case "dev":
		s.runDev()
	case "staging":
		s.runStaging()
	case "prod":
		s.runProd()
	default:
		panic("unsupported environment")
	}
}

func (s *server) runDev() {
	s.r.Use(cors.Default())
	s.setupAPIs()

	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}

func (s *server) runStaging() {
	s.serveStatic("/web/", "./web")
	s.setupAPIs()

	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}

func (s *server) runProd() {
	s.serveStatic("/web/", "./web")
	s.setupAPIs()

	s.r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})
	log.Fatal(autotls.Run(s.r, config.App().Domains...))
}

func (s *server) serveStatic(relativePath, root string) {
	s.r.Use(addCacheControlHeaderFor(relativePath))
	s.r.Static(relativePath, root)
}

func addCacheControlHeaderFor(prefix string) func(*gin.Context) {
	return func(c *gin.Context) {
		if strings.HasPrefix(c.Request.RequestURI, prefix) {
			c.Header("Cache-Control", "max-age=3600")
			c.Next()
		}
	}
}
