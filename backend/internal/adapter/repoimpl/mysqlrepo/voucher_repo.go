package mysqlrepo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"

	"gorm.io/gorm"
)

func NewVoucherRepo(db *gorm.DB) repo.Voucher {
	return &voucherRepo{db}
}

type voucherRepo struct {
	db *gorm.DB
}

func (r *voucherRepo) Create(voucher *entity.Voucher) error {
	result := r.db.Create(voucher)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates voucher")
	}
	return nil
}

func (r *voucherRepo) GetByCode(code string) *entity.Voucher {
	voucher := new(entity.Voucher)
	result := r.db.Where("code = ?", code).First(voucher)
	if result.Error != nil {
		return nil
	}
	return voucher
}

func (r *voucherRepo) DeleteByCode(code string) error {
	result := r.db.Where("code = ?", code).Delete(entity.Voucher{})
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm db delete voucher code '%s'", code)
	}
	return nil
}
