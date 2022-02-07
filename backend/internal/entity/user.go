package entity

type User struct {
	Username     string `json:"username"`
	Password     string `json:"password"`
	PasswordSalt string `json:"passwordSalt"`
	FullName     string `json:"fullName"`
	Role         string `json:"role"`
	Active       bool   `json:"active"`
}
