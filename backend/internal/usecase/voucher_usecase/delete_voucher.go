package voucher_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewDeleteVoucherUsecase(vr repo.Voucher) *DeleteVoucherUsecase {
	return &DeleteVoucherUsecase{vr}
}

type DeleteVoucherUsecase struct {
	voucherRepo repo.Voucher
}

type DeleteVoucherInput struct {
	Code string `json:"code"`
}

func (i *DeleteVoucherInput) validate() error {
	if i.Code == "" {
		return apperror.New("code must be provided")
	}
	return nil
}

func (u *DeleteVoucherUsecase) Delete(input *DeleteVoucherInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	voucher := u.voucherRepo.GetByCode(input.Code)
	if voucher.IsUsed {
		return apperror.New("cannot delete used voucher").
			WithCode(http.StatusForbidden)
	}

	if err := u.voucherRepo.DeleteByCode(input.Code); err != nil {
		return apperror.Wrap(err, "repo deletes voucher")
	}

	return nil
}
