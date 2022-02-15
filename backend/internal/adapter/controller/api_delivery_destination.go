package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/delivery_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) createDeliveryDest(c *gin.Context) {
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

func (s *server) refreshDeliveryDestSecurityCode(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(delivery_usecase.RefreshSecurityCodeInput)
	body.Name = c.Param("name")

	refreshSecurityCodeUsecase := delivery_usecase.NewRefreshSecurityCodeUsecase(s.deliveryRepo)
	if err := refreshSecurityCodeUsecase.Refresh(time.Now(), body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase refreshes security code"))
		return
	}

	response.Success(c, true)
}

func (s *server) deleteDeliveryDest(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(delivery_usecase.DeleteDestInput)
	body.Name = c.Param("name")

	deleteDestUsecase := delivery_usecase.NewDeleteDestUsecase(s.deliveryRepo)
	if err := deleteDestUsecase.Delete(body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase deletes delivery destination"))
		return
	}

	response.Success(c, true)
}
