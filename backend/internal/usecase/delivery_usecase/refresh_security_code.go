package delivery_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewRefreshSecurityCodeUsecase(dr repo.Delivery) *RefreshSecurityCodeUsecase {
	return &RefreshSecurityCodeUsecase{dr}
}

type RefreshSecurityCodeUsecase struct {
	deliveryRepo repo.Delivery
}

type RefreshSecurityCodeInput struct {
	Name string `json:"name"`
}

func (i *RefreshSecurityCodeInput) validate() error {
	if i.Name == "" {
		return apperror.New("name must be provided")
	}
	return nil
}

func (u *RefreshSecurityCodeUsecase) Refresh(t time.Time, input *RefreshSecurityCodeInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	dest := u.deliveryRepo.GetByName(input.Name)
	if dest == nil {
		return apperror.New("delivery destination not found").
			WithCode(http.StatusBadRequest)
	}

	dest.SecurityCode = genNewSecurityCode(t)
	if err := u.deliveryRepo.Update(dest); err != nil {
		return apperror.Wrap(err, "repo update delivery destination")
	}

	return nil
}
