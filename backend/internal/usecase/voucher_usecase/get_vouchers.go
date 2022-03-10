package voucher_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetVouchersUsecase(vr repo.Voucher) *GetVouchersUsecase {
	return &GetVouchersUsecase{vr}
}

type GetVouchersUsecase struct {
	voucherRepo repo.Voucher
}

func (u *GetVouchersUsecase) GetVouchers() ([]*entity.Voucher, error) {
	vouchers, err := u.voucherRepo.GetMany()
	if err != nil {
		return nil, apperror.Wrap(err, "voucherRepo gets vouchers")
	}
	return vouchers, nil
}
