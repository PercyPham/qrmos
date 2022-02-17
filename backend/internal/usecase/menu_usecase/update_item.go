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
	BaseUnitPrice int                      `json:"baseUnitPrice"`
	Options       []*entity.MenuItemOption `json:"options"`
	Categories    []int                    `json:"categories"`
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

	for _, catID := range input.Categories {
		if category := u.menuRepo.GetCategoryByID(catID); category == nil {
			return apperror.Newf("category '%d' does not exist", catID).WithCode(http.StatusNotFound)
		}
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

	if err := u.reassociate(item.ID, input.Categories); err != nil {
		return apperror.Wrap(err, "reassociate item with categories")
	}

	return nil
}

func (u *UpdateMenuItemUsecase) reassociate(itemID int, catIDs []int) error {
	currentCatIDs, err := u.menuRepo.GetAllCatIDsOfItem(itemID)
	if err != nil {
		return apperror.Wrapf(err, "repo gets current cats of item '%d'", itemID)
	}

	catIDsToAdd := excludeListFromList(currentCatIDs, catIDs)
	for _, catID := range catIDsToAdd {
		if err := u.menuRepo.AddItemToCategory(itemID, catID); err != nil {
			return apperror.Wrapf(err, "repo associate item '%d' to cat '%d'", itemID, catID)
		}
	}

	catIDsToRemove := excludeListFromList(catIDs, currentCatIDs)
	for _, catID := range catIDsToRemove {
		if err := u.menuRepo.RemoveItemFromCategory(itemID, catID); err != nil {
			return apperror.Wrapf(err, "repo disassociate item '%d' from cat '%d'", itemID, catID)
		}
	}

	return nil
}

func excludeListFromList(listToExclude, listToInclude []int) []int {
	result := []int{}
	m := map[int]bool{}
	for _, n := range listToInclude {
		m[n] = true
	}
	for _, n := range listToExclude {
		delete(m, n)
	}
	for key := range m {
		result = append(result, key)
	}
	return result
}
