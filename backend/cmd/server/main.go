package main

import (
	"qrmos/internal/adapter/repoimpl/mysqlrepo"
	"qrmos/internal/adapter/rest"
)

func main() {
	db, err := mysqlrepo.Connect()
	if err != nil {
		panic(err)
	}

	userRepo := mysqlrepo.NewUserRepo(db)

	server := rest.NewServer(userRepo)

	server.Run(5000)
}
