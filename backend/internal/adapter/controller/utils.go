package controller

import (
	"net/http"
	"qrmos/internal/common/apperror"
)

func newBindJsonReqBodyError(err error) error {
	return apperror.Wrap(err, "bind json req body").
		WithCode(http.StatusBadRequest).
		WithPublicMessage("req json body: " + apperror.RootCause(err).Error())
}

func newUnauthorizedError(err error) error {
	return apperror.Wrap(err, "authorize").
		WithCode(http.StatusUnauthorized).
		WithPublicMessage("unauthorized")
}
