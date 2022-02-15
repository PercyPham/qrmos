package user_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"time"
)

type CreateUserInput struct {
	Username string `json:"username"`
	Password string `json:"password"`
	FullName string `json:"fullName"`
	Role     string `json:"role"`
}

func (i *CreateUserInput) validate() error {
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

func (u *UserUsecase) CreateUser(t time.Time, input *CreateUserInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}
	user := u.userRepo.GetUserByUsername(input.Username)
	if user != nil {
		return apperror.New("username already exists")
	}
	user = &entity.User{
		Username: input.Username,
		FullName: input.FullName,
		Role:     input.Role,
		Active:   true,
	}
	user.SetPassword(t, input.Password)
	if err := u.userRepo.CreateUser(user); err != nil {
		return apperror.Wrap(err, "user repo creates user")
	}
	return nil
}
