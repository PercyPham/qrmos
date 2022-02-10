package entity

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/common/security"
	"time"
)

const UserRoleAdmin = "admin"
const UserRoleManager = "manager"
const UserRoleNormalStaff = "normal-staff"

type User struct {
	Username     string `json:"username"`
	Password     string `json:"password"`
	PasswordSalt string `json:"passwordSalt"`
	FullName     string `json:"fullName"`
	Role         string `json:"role"`
	Active       bool   `json:"active"`
}

func (u *User) SetPassword(t time.Time, password string) error {
	if err := u.validatePasswordFormat(password); err != nil {
		return apperror.Wrap(err, "validate new password format")
	}
	u.PasswordSalt = security.GenRanStr(t, 50)
	u.Password = security.HashHS256(password+u.PasswordSalt, config.App().Secret)
	return nil
}

func (u *User) CheckPassword(password string) bool {
	hashedPassword := security.HashHS256(password+u.PasswordSalt, config.App().Secret)
	return hashedPassword == u.Password
}

func (u *User) validatePasswordFormat(password string) error {
	if password == "" {
		return apperror.New("password must not be empty")
	}
	return nil
}
