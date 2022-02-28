package voucher_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewCreateVoucherUsecase(vr repo.Voucher) *CreateVoucherUsecase {
	return &CreateVoucherUsecase{vr}
}

type CreateVoucherUsecase struct {
	voucherRepo repo.Voucher
}

type CreateVoucherInput struct {
	Code      string `json:"code"`
	Discount  int64  `json:"discount"`
	CreatedBy string
}

func (i *CreateVoucherInput) validate() error {
	if i.Code == "" {
		return apperror.New("code must be provided")
	}
	if i.Discount <= 0 {
		return apperror.New("discount must be greater than zero")
	}
	if i.CreatedBy == "" {
		return apperror.New("createdBy must be provided")
	}
	return nil
}

func (u *CreateVoucherUsecase) Create(input *CreateVoucherInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	voucher := u.voucherRepo.GetByCode(input.Code)
	if voucher != nil {
		return apperror.New("voucher already exists")
	}
	voucher = &entity.Voucher{
		Code:      input.Code,
		Discount:  input.Discount,
		IsUsed:    false,
		CreatedBy: input.CreatedBy,
	}
	if err := u.voucherRepo.Create(voucher); err != nil {
		return apperror.Wrap(err, "repo creates voucher")
	}
	return nil
}
