package main

import (
	"qrmos/internal/adapter/repoimpl/mysqlrepo"
	"qrmos/internal/adapter/rest"
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

	server := rest.NewServer(userRepo)

	server.Run()
}
