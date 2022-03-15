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

func getIntQuery(c *gin.Context, key string) (int, error) {
	raw := c.Query(key)
	num, err := strconv.ParseInt(raw, 10, 32)
	if err != nil {
		return 0, apperror.Wrapf(err, "parse '%s' query to int", key).
			WithCode(http.StatusBadRequest).
			WithPublicMessagef("expected '%s' query to be int, got '%v'", key, raw)
	}
	return int(num), err
}

func getInt64Query(c *gin.Context, key string) (int64, error) {
	raw := c.Query(key)
	num, err := strconv.ParseInt(raw, 10, 64)
	if err != nil {
		return 0, apperror.Wrapf(err, "parse '%s' query to int64", key).
			WithCode(http.StatusBadRequest).
			WithPublicMessagef("expected '%s' query to be int64, got '%v'", key, raw)
	}
	return num, err
}

func getBoolQuery(c *gin.Context, key string) (bool, error) {
	val := c.Query(key)
	if val == "true" {
		return true, nil
	}
	if val == "false" {
		return false, nil
	}
	if val == "" {
		apperror.Newf("expected boolean query with key '%s'", key).
			WithCode(http.StatusBadRequest)
	}
	return false, apperror.Newf("expected boolean query with key '%s', got '%s'", key, val).
		WithCode(http.StatusBadRequest)
}
