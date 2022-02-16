package main

import (
	"log"
	"qrmos/internal/adapter/repoimpl/mysqlrepo"
	"qrmos/internal/common/config"
	"qrmos/internal/entity"
	"time"

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

	admin := &entity.User{
		Username: "admin",
		FullName: "Admin",
		Role:     entity.UserRoleAdmin,
		Active:   true,
	}
	admin.SetPassword(time.Now(), "password")

	if err := userRepo.Create(admin); err != nil {
		log.Fatal("cannot create admin user: ", err)
	}
}
