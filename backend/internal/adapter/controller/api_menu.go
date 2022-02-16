package controller

import (
	"net/http"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/menu_usecase"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) createMenuCat(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(menu_usecase.CreateCategoryInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	createMenuCatUsecase := menu_usecase.NewCreateCategoryUsecase(s.menuRepo)
	cat, err := createMenuCatUsecase.Create(body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates menu category"))
		return
	}

	response.Success(c, cat)
}

func (s *server) deleteMenuCat(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	catIDRaw := c.Param("id")
	catID, err := strconv.ParseInt(catIDRaw, 10, 32)
	if err != nil {
		appErr := apperror.Wrap(err, "casting category id").
			WithCode(http.StatusBadRequest).
			WithPublicMessagef("expected int32 category id, got '%v'", catIDRaw)
		response.Error(c, appErr)
		return
	}

	deleteMenuCatUsecase := menu_usecase.NewDeleteCatUsecase(s.menuRepo)
	err = deleteMenuCatUsecase.DeleteByID(int(catID))
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates menu category"))
		return
	}

	response.Success(c, true)
}
