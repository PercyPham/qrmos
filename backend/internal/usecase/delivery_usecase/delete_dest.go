package delivery_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewDeleteDestUsecase(dr repo.Delivery) *DeleteDestUsecase {
	return &DeleteDestUsecase{dr}
}

type DeleteDestUsecase struct {
	deliveryRepo repo.Delivery
}

type DeleteDestInput struct {
	Name string `json:"name"`
}

func (i *DeleteDestInput) validate() error {
	if i.Name == "" {
		return apperror.New("name must be provided")
	}
	return nil
}

func (u *DeleteDestUsecase) Delete(input *DeleteDestInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	if err := u.deliveryRepo.DeleteByName(input.Name); err != nil {
		return apperror.Wrap(err, "repo delete delivery destination")
	}

	return nil
}
