package mysqlrepo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func Connect() (*gorm.DB, error) {
	dsn := config.MySQL().DSN
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, apperror.Wrap(err, "open gorm db connection")
	}
	return db, nil
}
