package customer_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/internal/token"
)

func NewUpdateCustomerUsecase() *UpdateCustomerUsecase {
	return &UpdateCustomerUsecase{}
}

type UpdateCustomerUsecase struct {
}

type UpdateCustomerInput struct {
	CustomerID  string `json:"customerId"`
	FullName    string `json:"fullName"`
	PhoneNumber string `json:"phoneNumber"`
}

func (i *UpdateCustomerInput) validate() error {
	if i.CustomerID == "" {
		return apperror.New("customerId must be provided")
	}
	if i.FullName == "" {
		return apperror.New("fullName must be provided")
	}
	if i.PhoneNumber == "" {
		return apperror.New("phoneNumber must be provided")
	}
	return nil
}

func (u *UpdateCustomerUsecase) UpdateCustomer(input *UpdateCustomerInput) (string, error) {
	if err := input.validate(); err != nil {
		return "", apperror.Wrap(err, "validate customer input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}
	customer := &entity.Customer{
		ID:          input.CustomerID,
		FullName:    input.FullName,
		PhoneNumber: input.PhoneNumber,
	}
	newCustomerAccessToken, err := token.GenCustomerAccessToken(customer)
	if err != nil {
		return "", apperror.Wrap(err, "gen new customer access token")
	}
	return newCustomerAccessToken, nil
}
