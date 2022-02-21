package menu_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewUpdateItemAvailUsecase(mr repo.Menu) *UpdateItemAvailUsecase {
	return &UpdateItemAvailUsecase{mr}
}

type UpdateItemAvailUsecase struct {
	menuRepo repo.Menu
}

func (u *UpdateItemAvailUsecase) UpdateItemAvail(itemID int, val bool) error {
	item := u.menuRepo.GetItemByID(itemID)
	if item == nil {
		return apperror.New("item not found").WithCode(http.StatusNotFound)
	}
	if item.Available == val {
		return nil
	}
	item.Available = val
	if err := u.menuRepo.UpdateItem(item); err != nil {
		return apperror.Wrap(err, "repo updates menu item")
	}
	return nil
}

func (u *UpdateItemAvailUsecase) UpdateItemOptionAvail(itemID int, optName string, val bool) error {
	item := u.menuRepo.GetItemByID(itemID)
	if item == nil {
		return apperror.New("item not found").WithCode(http.StatusNotFound)
	}

	foundOption, ok := item.Options[optName]
	if !ok {
		return apperror.New("item option not found").WithCode(http.StatusNotFound)
	}

	if foundOption.Available == val {
		return nil
	}

	foundOption.Available = val
	if err := u.menuRepo.UpdateItem(item); err != nil {
		return apperror.Wrap(err, "repo updates menu item")
	}

	return nil
}

func (u *UpdateItemAvailUsecase) UpdateItemOptionChoiceAvail(itemID int, optName, choiceName string, val bool) error {
	item := u.menuRepo.GetItemByID(itemID)
	if item == nil {
		return apperror.New("item not found").WithCode(http.StatusNotFound)
	}

	foundOption, ok := item.Options[optName]
	if !ok {
		return apperror.New("item option not found").WithCode(http.StatusNotFound)
	}

	foundChoice, ok := foundOption.Choices[choiceName]
	if !ok {
		return apperror.New("item option choice not found").WithCode(http.StatusNotFound)
	}

	if foundChoice.Available == val {
		return nil
	}

	foundChoice.Available = val
	if err := u.menuRepo.UpdateItem(item); err != nil {
		return apperror.Wrap(err, "repo updates menu item")
	}

	return nil
}
