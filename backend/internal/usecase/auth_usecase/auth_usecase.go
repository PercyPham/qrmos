package auth_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/internal/token"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewAuthUsecase(ur repo.UserRepo) *AuthUsecase {
	return &AuthUsecase{ur}
}

type AuthUsecase struct {
	userRepo repo.UserRepo
}

func (u *AuthUsecase) AuthenticateStaff(t time.Time, accessToken string) (*entity.User, error) {
	staffAccessTokenClaims, err := token.ValidateStaffAccessToken(t, accessToken)
	if err != nil {
		return nil, apperror.Wrap(err, "validate staff access token")
	}
	user := u.userRepo.GetUserByUsername(staffAccessTokenClaims.Username)
	if user == nil {
		return nil, apperror.Wrapf(err, "user repo gets user with username 'v'", staffAccessTokenClaims.Username)
	}
	if !user.Active {
		return nil, apperror.New("user is not active").
			WithCode(http.StatusForbidden)
	}
	if !token.CheckStaffTokenKey(staffAccessTokenClaims.Key, user.Password) {
		return nil, apperror.New("user password has changed").
			WithCode(http.StatusUnauthorized)
	}
	return user, nil
}

func (u *AuthUsecase) AuthenticateCustomer(accessToken string) (*entity.Customer, error) {
	customerAccessToken, err := token.ValidateCustomerAccessTokent(accessToken)
	if err != nil {
		return nil, apperror.Wrap(err, "validate customer access token")
	}
	customer := &entity.Customer{
		ID:          customerAccessToken.CustomerID,
		FullName:    customerAccessToken.FullName,
		PhoneNumber: customerAccessToken.PhoneNumber,
	}
	return customer, nil
}
