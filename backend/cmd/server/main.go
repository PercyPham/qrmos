package main

import (
	"qrmos/internal/adapter/controller"
	"qrmos/internal/adapter/repoimpl/mysqlrepo"
	"qrmos/internal/common/config"

	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load() // load `.env` if has
	godotenv.Load(".default.env")
	config.Load()

	db, err := mysqlrepo.Connect()
	if err != nil {
		panic(err)
	}

	serverCfg := controller.ServerConfig{
		UserRepo:     mysqlrepo.NewUserRepo(db),
		DeliveryRepo: mysqlrepo.NewDeliveryRepo(db),
		MenuRepo:     mysqlrepo.NewMenuRepo(db),
	}
	server := controller.NewServer(serverCfg)

	server.Run()
}
