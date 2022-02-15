package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/delivery_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) createDeliveryDestination(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(delivery_usecase.CreateDestInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	createDestUsecase := delivery_usecase.NewCreateDestUsecase(s.deliveryRepo)
	if err := createDestUsecase.Create(time.Now(), body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates delivery destination"))
		return
	}

	response.Success(c, true)
}
