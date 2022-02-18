package delivery_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/security"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewCreateDestUsecase(dr repo.Delivery) *CreateDestUsecase {
	return &CreateDestUsecase{dr}
}

type CreateDestUsecase struct {
	DeliveryRepo repo.Delivery
}

type CreateDestInput struct {
	Name string `json:"name"`
}

func (i *CreateDestInput) validate() error {
	if i.Name == "" {
		return apperror.New("name must be provided")
	}
	return nil
}

func (u *CreateDestUsecase) Create(t time.Time, input *CreateDestInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}
	deliverDest := u.DeliveryRepo.GetByName(input.Name)
	if deliverDest != nil {
		return apperror.New("delivery destination already exists")
	}
	deliverDest = &entity.DeliveryDestination{
		Name:         input.Name,
		SecurityCode: genNewSecurityCode(t),
	}
	if err := u.DeliveryRepo.Create(deliverDest); err != nil {
		return apperror.Wrap(err, "repo creates deliver destination")
	}
	return nil
}

func genNewSecurityCode(t time.Time) string {
	return security.GenRanStr(t, 15)
}
