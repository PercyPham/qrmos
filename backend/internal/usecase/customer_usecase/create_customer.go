package customer_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/internal/token"

	"github.com/google/uuid"
)

func NewCreateCustomerUsecase() *CreateCustomerUsecase {
	return &CreateCustomerUsecase{}
}

type CreateCustomerUsecase struct {
}

type CreateCustomerInput struct {
	FullName    string `json:"fullName"`
	PhoneNumber string `json:"phoneNumber"`
}

func (i *CreateCustomerInput) validate() error {
	if i.FullName == "" {
		return apperror.New("fullName must be provided")
	}
	if i.PhoneNumber == "" {
		return apperror.New("phoneNumber must be provided")
	}
	return nil
}

func (u *CreateCustomerUsecase) CreateCustomer(input *CreateCustomerInput) (customerAccessToken string, err error) {
	if err := input.validate(); err != nil {
		return "", apperror.Wrap(err, "validate customer input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}
	customer := &entity.Customer{
		ID:          uuid.New().String(),
		FullName:    input.FullName,
		PhoneNumber: input.PhoneNumber,
	}
	customerAccessToken, err = token.GenCustomerAccessToken(customer)
	if err != nil {
		return "", apperror.Wrap(err, "gen customer access token")
	}
	return customerAccessToken, nil
}
