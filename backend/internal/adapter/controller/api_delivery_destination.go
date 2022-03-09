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
	if _, err := s.authCheck.IsManager(now, c); err != nil {
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

func (s *server) getDestByName(c *gin.Context) {
	if _, err := s.authCheck.IsStaff(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	destName := c.Param("name")

	destUsecase := delivery_usecase.NewGetDeliveryDestUsecase(s.deliveryRepo)
	dest, err := destUsecase.GetDeliveryDestByName(destName)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets delivery destination by name"))
		return
	}
	response.Success(c, dest)

}

func (s *server) getAllDests(c *gin.Context) {
	if _, err := s.authCheck.IsCustomer(c); err == nil {
		s.getAllDestsAsCus(c)
		return
	}

	if _, err := s.authCheck.IsStaff(time.Now(), c); err == nil {
		s.getAllDestsAsStaff(c)
		return
	}

	response.Error(c, newUnauthorizedError(apperror.New("unauthenticated")))
}

func (s *server) getAllDestsAsStaff(c *gin.Context) {
	destUsecase := delivery_usecase.NewGetDeliveryDestUsecase(s.deliveryRepo)
	dests, err := destUsecase.GetDeliveryDestionations()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets delivery destinations"))
		return
	}
	response.Success(c, dests)
}

func (s *server) getAllDestsAsCus(c *gin.Context) {
	destUsecase := delivery_usecase.NewGetDeliveryDestUsecase(s.deliveryRepo)
	dests, err := destUsecase.GetDeliveryDestionationsAsCustomer()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets delivery destinations as customer"))
		return
	}
	response.Success(c, dests)
}

func (s *server) refreshDeliveryDestSecurityCode(c *gin.Context) {
	now := time.Now()
	if _, err := s.authCheck.IsManager(now, c); err != nil {
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
	if _, err := s.authCheck.IsManager(now, c); err != nil {
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
