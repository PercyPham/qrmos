package apperror

import (
	"fmt"
	"net/http"
)

type AppError interface {
	Error() string
	Code() int
	// PublicMessage returns the public message associated with the error.
	// This message intends to be sent to public user in production mode.
	PublicMessage() string
	// WithCode sets AppError's code.
	WithCode(code int) AppError
	// WithPublicMessage sets AppError's public message.
	WithPublicMessage(string) AppError
	// WithPublicMessagef formats the error message
	// and sets it to AppError's public message.
	WithPublicMessagef(format string, args ...interface{}) AppError
}

// New returns a new AppError with status code and message
func New(code int, message string) AppError {
	return &appErr{
		code:      code,
		msg:       message,
		publicMsg: message,
	}
}

// Newf formats error message and returns a new AppError with
// status code and message
func Newf(code int, format string, args ...interface{}) AppError {
	message := fmt.Sprintf(format, args...)
	return &appErr{
		code:      code,
		msg:       message,
		publicMsg: message,
	}
}

// Wrap wraps an error and returns a new AppError with error status
// code as same as wrapped error (default to InternalServerError)
func Wrap(err error, message string) AppError {
	return wrap(err, message)
}

// Wrap formats error message, wraps an error and returns a new AppError with
// error status code as same as wrapped error (default to InternalServerError)
func Wrapf(err error, format string, args ...interface{}) AppError {
	message := fmt.Sprintf(format, args...)
	return wrap(err, message)
}

func wrap(err error, message string) AppError {
	if err == nil {
		return nil
	}
	code := http.StatusInternalServerError
	if aErr, ok := err.(AppError); ok {
		code = aErr.Code()
	}
	return &appErr{cause: err, msg: message, code: code}
}

type appErr struct {
	cause     error
	msg       string
	code      int
	publicMsg string
}

// Unwrap provides compatibility for Go 1.13 error chains.
func (e *appErr) Unwrap() error { return e.cause }

// Code returns the error code associated with the error message
func (e *appErr) Code() int { return e.code }

func (e *appErr) Error() string {
	if e.cause == nil {
		return e.msg
	}
	return e.msg + ": " + e.cause.Error()
}

func (e *appErr) PublicMessage() string {
	if e.publicMsg != "" {
		return e.publicMsg
	}
	if e.cause == nil {
		return "internal server error"
	}
	if aErr, ok := e.cause.(AppError); ok {
		return aErr.PublicMessage()
	}
	return "internal server error"
}

func (e *appErr) WithCode(code int) AppError {
	e.code = code
	return e
}

func (e *appErr) WithPublicMessage(m string) AppError {
	e.publicMsg = m
	return e
}

func (e *appErr) WithPublicMessagef(format string, args ...interface{}) AppError {
	e.publicMsg = fmt.Sprintf(format, args...)
	return e
}
