package repo

import "qrmos/internal/entity"

type UserRepo interface {
	GetUsers() ([]*entity.User, error)
}
