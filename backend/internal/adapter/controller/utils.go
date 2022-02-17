package controller

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"strconv"

	"github.com/gin-gonic/gin"
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

func getIntParam(c *gin.Context, key string) (int, error) {
	raw := c.Param(key)
	num, err := strconv.ParseInt(raw, 10, 32)
	if err != nil {
		return 0, apperror.Wrapf(err, "parse '%s' param to int", key).
			WithCode(http.StatusBadRequest).
			WithPublicMessagef("expected '%s' param to be int, got '%v'", key, raw)
	}
	return int(num), err
}
