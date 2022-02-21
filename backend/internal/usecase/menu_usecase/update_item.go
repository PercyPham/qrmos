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
	ID            int                      `json:"id"`
	Name          string                   `json:"name"`
	Description   string                   `json:"description"`
	Image         string                   `json:"image"`
	Available     bool                     `json:"available"`
	BaseUnitPrice int64                    `json:"baseUnitPrice"`
	Options       []*entity.MenuItemOption `json:"options"`
}

func (i *UpdateMenuItemInput) validate() error {
	if i.Name == "" {
		return apperror.New("name must be provided")
	}
	if i.Image == "" {
		return apperror.New("image must be provided")
	}
	if i.BaseUnitPrice <= 0 {
		return apperror.New("baseUnitPrice must be greater than 0")
	}
	for i, option := range i.Options {
		if err := validateMenuItemOption(option); err != nil {
			return apperror.Wrapf(err, "validate item option %d", i)
		}
	}
	return nil
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
