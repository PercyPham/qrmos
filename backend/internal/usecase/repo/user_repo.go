package repo

import "qrmos/internal/entity"

type UserRepo interface {
	CreateUser(user *entity.User) error
	GetUsers() ([]*entity.User, error)
}
