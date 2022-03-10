package repo

import "qrmos/internal/entity"

type Voucher interface {
	Create(*entity.Voucher) error
	GetMany() ([]*entity.Voucher, error)
	GetByCode(code string) *entity.Voucher
	Update(*entity.Voucher) error
	DeleteByCode(code string) error
}
