package mysqlrepo

import (
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func Connect() (*gorm.DB, error) {
	dsn := "admin:password@tcp(127.0.0.1:3306)/qrmos?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	return db, nil
}
