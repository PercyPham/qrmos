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

func (s *server) deleteMenuCat(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	catID, err := getIntParam(c, "id")
	if err != nil {
		response.Error(c, err)
		return
	}

	deleteMenuCatUsecase := menu_usecase.NewDeleteCatUsecase(s.menuRepo)
	err = deleteMenuCatUsecase.DeleteByID(catID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase deletes menu category"))
		return
	}

	response.Success(c, true)
}

func (s *server) createMenuItem(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(menu_usecase.CreateMenuItemInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	createMenuItemUsecase := menu_usecase.NewCreateMenuItemUsecase(s.menuRepo)
	item, err := createMenuItemUsecase.Create(body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates menu item"))
		return
	}

	response.Success(c, item)
}

func (s *server) updateMenuItem(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	itemID, err := getIntParam(c, "itemID")
	if err != nil {
		response.Error(c, err)
		return
	}

	body := new(menu_usecase.UpdateMenuItemInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}
	body.ID = int(itemID)

	updateMenuItemUsecase := menu_usecase.NewUpdateMenuItemUsecase(s.menuRepo)
	err = updateMenuItemUsecase.Update(body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase updates menu item"))
		return
	}

	response.Success(c, true)
}

func (s *server) updateItemAvail(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsStaff(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	itemID, err := getIntParam(c, "itemID")
	if err != nil {
		response.Error(c, err)
		return
	}
	val, err := getBoolQuery(c, "val")
	if err != nil {
		response.Error(c, err)
		return
	}

	updateItemAvailUsecase := menu_usecase.NewUpdateItemAvailUsecase(s.menuRepo)
	err = updateItemAvailUsecase.UpdateItemAvail(itemID, val)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase updates menu item avail"))
		return
	}

	response.Success(c, true)
}

func (s *server) updateItemOptionAvail(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsStaff(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	itemID, err := getIntParam(c, "itemID")
	if err != nil {
		response.Error(c, err)
		return
	}
	optName := c.Param("optName")
	val, err := getBoolQuery(c, "val")
	if err != nil {
		response.Error(c, err)
		return
	}

	updateItemAvailUsecase := menu_usecase.NewUpdateItemAvailUsecase(s.menuRepo)
	err = updateItemAvailUsecase.UpdateItemOptionAvail(itemID, optName, val)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase updates menu item avail"))
		return
	}

	response.Success(c, true)
}
func (s *server) updateItemOptionChoiceAvail(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsStaff(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	itemID, err := getIntParam(c, "itemID")
	if err != nil {
		response.Error(c, err)
		return
	}
	optName := c.Param("optName")
	choiceName := c.Param("choiceName")
	val, err := getBoolQuery(c, "val")
	if err != nil {
		response.Error(c, err)
		return
	}

	updateItemAvailUsecase := menu_usecase.NewUpdateItemAvailUsecase(s.menuRepo)
	err = updateItemAvailUsecase.UpdateItemOptionChoiceAvail(itemID, optName, choiceName, val)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase updates menu item avail"))
		return
	}

	response.Success(c, true)
}

func (s *server) deleteMenuItem(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	itemID, err := getIntParam(c, "id")
	if err != nil {
		response.Error(c, err)
		return
	}

	deleteMenuItemUsecase := menu_usecase.NewDeleteItemUsecase(s.menuRepo)
	err = deleteMenuItemUsecase.DeleteByID(itemID)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase deletes menu item"))
		return
	}

	response.Success(c, true)
}
