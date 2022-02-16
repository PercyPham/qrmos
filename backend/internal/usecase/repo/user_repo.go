package repo

import "qrmos/internal/entity"

type User interface {
	Create(user *entity.User) error
	GetMany() ([]*entity.User, error)
	GetByUsername(username string) *entity.User
	Update(user *entity.User) error
}
