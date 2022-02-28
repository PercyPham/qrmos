package main

import (
	"qrmos/internal/adapter/controller"
	"qrmos/internal/adapter/repoimpl/mysqlrepo"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"

	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load() // load `.env` if has
	godotenv.Load(".default.env")
	config.Load()

	db, err := mysqlrepo.Connect()
	if err != nil {
		panic(apperror.Wrap(err, "connect to mysql db"))
	}

	serverCfg := controller.ServerConfig{
		UserRepo:        mysqlrepo.NewUserRepo(db),
		DeliveryRepo:    mysqlrepo.NewDeliveryRepo(db),
		MenuRepo:        mysqlrepo.NewMenuRepo(db),
		VoucherRepo:     mysqlrepo.NewVoucherRepo(db),
		OrderRepo:       mysqlrepo.NewOrderRepo(db),
		StoreConfigRepo: mysqlrepo.NewStoreConfigRepo(db),
	}
	server, err := controller.NewServer(serverCfg)
	if err != nil {
		panic(apperror.Wrap(err, "instanciate new server"))
	}

	server.Run()
}
