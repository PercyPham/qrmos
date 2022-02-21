package menu_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewUpdateMenuItemUsecase(mr repo.Menu) *UpdateMenuItemUsecase {
	return &UpdateMenuItemUsecase{mr}
}

type UpdateMenuItemUsecase struct {
	menuRepo repo.Menu
}

type UpdateMenuItemInput struct {
	ID int `json:"id"`
	CreateMenuItemInput
}

func (i *UpdateMenuItemInput) validate() error {
	return i.CreateMenuItemInput.validate()
}

func (u *UpdateMenuItemUsecase) Update(input *UpdateMenuItemInput) error {
	if err := input.validate(); err != nil {
		return apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	item := u.menuRepo.GetItemByID(input.ID)
	if item == nil {
		return apperror.Newf("item '%d' does not exist", input.ID).WithCode(http.StatusNotFound)
	}

	item = &entity.MenuItem{
		ID:            input.ID,
		Name:          input.Name,
		Description:   input.Description,
		Image:         input.Image,
		Available:     input.Available,
		BaseUnitPrice: input.BaseUnitPrice,
		Options:       input.Options,
	}
	if err := u.menuRepo.UpdateItem(item); err != nil {
		return apperror.Wrap(err, "repo updates menu item")
	}

	return nil
}
