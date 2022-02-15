package user_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"time"
)

func NewUpdateUserUsecase(ur repo.UserRepo) *UpdateUserUsecase {
	return &UpdateUserUsecase{ur}
}

type UpdateUserUsecase struct {
	userRepo repo.UserRepo
}

type UpdateUserInput struct {
	Username string `json:"username"`
	Password string `json:"password"`
	FullName string `json:"fullName"`
	Role     string `json:"role"`
	Active   bool   `json:"active"`
}

func (i *UpdateUserInput) validate() error {
	if i.Username == "" {
		return apperror.New("username must be provided")
	}
	if i.Password == "" {
		return apperror.New("password must be provided")
	}
	if err := entity.ValidatePasswordFormat(i.Password); err != nil {
		return apperror.Wrap(err, "validate password format")
	}
	if i.FullName == "" {
		return apperror.New("fullName must be provided")
	}
	if i.Role == "" {
		return apperror.New("role must be provided")
	}
	if !(i.Role == entity.UserRoleAdmin || i.Role == entity.UserRoleManager || i.Role == entity.UserRoleNormalStaff) {
		return apperror.Newf("invalid role '%s'", i.Role)
	}
	return nil
}

func (u *UpdateUserUsecase) UpdateUser(t time.Time, input *UpdateUserInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	user := u.userRepo.GetUserByUsername(input.Username)
	if user == nil {
		return apperror.Newf("user '%s' not found", input.Username).WithCode(http.StatusNotFound)
	}

	if !user.CheckPassword(input.Password) {
		user.SetPassword(t, input.Password)
	}
	user.FullName = input.FullName
	user.Role = input.Role
	user.Active = input.Active

	if err := u.userRepo.UpdateUser(user); err != nil {
		return apperror.Wrap(err, "user repo update user")
	}

	return nil
}
