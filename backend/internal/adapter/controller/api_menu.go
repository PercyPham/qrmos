package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/menu_usecase"
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
