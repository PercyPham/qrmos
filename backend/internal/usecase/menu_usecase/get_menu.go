package menu_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetMenuUsecase(mr repo.Menu) *GetMenuUsecase {
	return &GetMenuUsecase{mr}
}

type GetMenuUsecase struct {
	menuRepo repo.Menu
}

func (u *GetMenuUsecase) GetMenu() (*Menu, error) {
	categories, err := u.menuRepo.GetAllCategories()
	if err != nil {
		return nil, apperror.Wrap(err, "repo gets categories")
	}

	associations, err := u.menuRepo.GetAllAssociations()
	if err != nil {
		return nil, apperror.Wrap(err, "repo gets associations")
	}

	items, err := u.menuRepo.GetAllItems()
	if err != nil {
		return nil, apperror.Wrap(err, "repo gets items")
	}

	return &Menu{
		Categories:   categories,
		Associations: associations,
		Items:        items,
	}, nil
}

type Menu struct {
	Categories   []*entity.MenuCategory    `json:"categories"`
	Items        []*entity.MenuItem        `json:"items"`
	Associations []*entity.MenuAssociation `json:"associations"`
}
