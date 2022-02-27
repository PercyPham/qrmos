package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/store_cfg_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) getStoreOpeningHoursConfig(c *gin.Context) {
	if _, err := s.authCheck.IsManager(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}
	openingHoursCfgUsecase := store_cfg_usecase.NewOpeningHoursConfigUsecase(s.storeConfigRepo)
	openingHours, err := openingHoursCfgUsecase.Get()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets store opening hours config"))
		return
	}
	response.Success(c, openingHours)
}

func (s *server) updateStoreOpeningHoursConfig(c *gin.Context) {
	if _, err := s.authCheck.IsManager(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(store_cfg_usecase.UpdateStoreOpeningHoursCfgInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	openingHoursCfgUsecase := store_cfg_usecase.NewOpeningHoursConfigUsecase(s.storeConfigRepo)
	if err := openingHoursCfgUsecase.Update(body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets store opening hours config"))
		return
	}
	response.Success(c, true)
}
