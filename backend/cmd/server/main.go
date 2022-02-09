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

	userRepo := mysqlrepo.NewUserRepo(db)

	server := controller.NewServer(userRepo)

	server.Run()
}
