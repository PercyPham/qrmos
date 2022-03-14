package controller

import (
	"log"
	"net/http"
	"qrmos/internal/adapter/controller/internal/authcheck"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/usecase/repo"
	"strconv"
	"strings"

	"github.com/gin-gonic/autotls"
	"github.com/gin-gonic/gin"
)

type ServerConfig struct {
	DBRepo          repo.DB
	UserRepo        repo.User
	DeliveryRepo    repo.Delivery
	MenuRepo        repo.Menu
	VoucherRepo     repo.Voucher
	OrderRepo       repo.Order
	OrderLogRepo    repo.OrderLog
	StoreConfigRepo repo.StoreConfig
}

func (cfg *ServerConfig) validate() error {
	if cfg.DBRepo == nil {
		return apperror.New("db repo must be provided")
	}
	if cfg.UserRepo == nil {
		return apperror.New("user repo must be provided")
	}
	if cfg.DeliveryRepo == nil {
		return apperror.New("delivery repo must be provided")
	}
	if cfg.MenuRepo == nil {
		return apperror.New("menu repo must be provided")
	}
	if cfg.VoucherRepo == nil {
		return apperror.New("voucher repo must be provided")
	}
	if cfg.OrderRepo == nil {
		return apperror.New("order repo must be provided")
	}
	if cfg.OrderLogRepo == nil {
		return apperror.New("order log repo must be provided")
	}
	if cfg.StoreConfigRepo == nil {
		return apperror.New("store config repo must be provided")
	}
	return nil
}

func NewServer(cfg ServerConfig) (*server, error) {
	if err := cfg.validate(); err != nil {
		return nil, apperror.Wrap(err, "validate server configs")
	}

	if config.App().ENV != "dev" {
		gin.SetMode(gin.ReleaseMode)
	}

	return &server{
		r:               gin.Default(),
		dbRepo:          cfg.DBRepo,
		userRepo:        cfg.UserRepo,
		deliveryRepo:    cfg.DeliveryRepo,
		menuRepo:        cfg.MenuRepo,
		voucherRepo:     cfg.VoucherRepo,
		orderRepo:       cfg.OrderRepo,
		orderLogRepo:    cfg.OrderLogRepo,
		storeConfigRepo: cfg.StoreConfigRepo,
		authCheck:       authcheck.NewAuthCheck(cfg.UserRepo),
	}, nil
}

type server struct {
	r *gin.Engine

	dbRepo          repo.DB
	userRepo        repo.User
	deliveryRepo    repo.Delivery
	menuRepo        repo.Menu
	voucherRepo     repo.Voucher
	orderRepo       repo.Order
	orderLogRepo    repo.OrderLog
	storeConfigRepo repo.StoreConfig

	authCheck *authcheck.AuthCheck
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
	s.r.Use(CORSMiddleware())
	s.serveImageStatic()
	s.setupAPIs()

	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Headers", "*")
		c.Header("Access-Control-Allow-Methods", "*")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	}
}

func (s *server) runStaging() {
	s.serveImageStatic()
	s.serveWebStatic()
	s.setupAPIs()

	port := strconv.Itoa(config.App().Port)
	s.r.Run(":" + port)
}

func (s *server) runProd() {
	s.serveImageStatic()
	s.serveWebStatic()
	s.setupAPIs()

	s.r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})
	log.Fatal(autotls.Run(s.r, config.App().Domains...))
}

func (s *server) serveImageStatic() {
	s.r.POST("/images", s.uploadImage)
	s.serveStatic("/images/", "./images")
}

func (s *server) serveWebStatic() {
	s.r.GET("/", func(c *gin.Context) {
		c.Redirect(http.StatusMovedPermanently, "/web/")
	})
	s.serveStatic("/web/", "./web")
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
