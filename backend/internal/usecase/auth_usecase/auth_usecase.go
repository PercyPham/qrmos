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
	staffAccessToken, err := token.ValidateStaffAccessToken(t, accessToken)
	if err != nil {
		return nil, apperror.Wrap(err, "validate staff access token")
	}
	user := u.userRepo.GetUserByUsername(staffAccessToken.Username)
	if user == nil {
		return nil, apperror.Wrapf(err, "user repo gets user with username 'v'", staffAccessToken.Username)
	}
	if !user.Active {
		return nil, apperror.New("user is not active").
			WithCode(http.StatusForbidden)
	}
	if !token.CheckStaffTokenKey(staffAccessToken.Key, user.Password) {
		return nil, apperror.New("user password has changed").
			WithCode(http.StatusUnauthorized)
	}
	return user, nil
}
