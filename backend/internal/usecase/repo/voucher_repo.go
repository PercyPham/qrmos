package repo

import "qrmos/internal/entity"

type Voucher interface {
	Create(*entity.Voucher) error
	GetByCode(code string) *entity.Voucher
	DeleteByCode(code string) error
}
