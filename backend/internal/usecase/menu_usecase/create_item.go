package menu_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewCreateMenuItemUsecase(mr repo.Menu) *CreateMenuItemUsecase {
	return &CreateMenuItemUsecase{mr}
}

type CreateMenuItemUsecase struct {
	menuRepo repo.Menu
}

type CreateMenuItemInput struct {
	Name          string                   `json:"name"`
	Description   string                   `json:"description"`
	Image         string                   `json:"image"`
	Available     bool                     `json:"available"`
	BaseUnitPrice int64                    `json:"baseUnitPrice"`
	Options       []*entity.MenuItemOption `json:"options"`
	Categories    []int                    `json:"categories"`
}

func (i *CreateMenuItemInput) validate() error {
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

func validateMenuItemOption(option *entity.MenuItemOption) error {
	if option.Name == "" {
		return apperror.New("option name must be provided")
	}
	if len(option.Choices) < 1 {
		return apperror.New("option choices must not be empty")
	}
	if option.MaxChoice < option.MinChoice {
		return apperror.New("option max choice must be greater then or equal to min choice")
	}
	if option.MaxChoice > len(option.Choices) {
		return apperror.New("option max choice must be less than or equal to max choice")
	}
	for i, choice := range option.Choices {
		if err := validateMenuItemOptionChoice(choice); err != nil {
			return apperror.Wrapf(err, "validate option choice %d", i)
		}
	}
	return nil
}

func validateMenuItemOptionChoice(choice *entity.MenuItemOptionChoice) error {
	if choice.Name == "" {
		return apperror.New("option choice name must be provided")
	}
	return nil
}

func (u *CreateMenuItemUsecase) Create(input *CreateMenuItemInput) (*entity.MenuItem, error) {
	if err := input.validate(); err != nil {
		return nil, apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	item := u.menuRepo.GetItemByName(input.Name)
	if item != nil {
		return nil, apperror.New("item already exists")
	}

	for _, catID := range input.Categories {
		if category := u.menuRepo.GetCategoryByID(catID); category == nil {
			return nil, apperror.Newf("category '%d' does not exist", catID).WithCode(http.StatusNotFound)
		}
	}

	item = &entity.MenuItem{
		Name:          input.Name,
		Description:   input.Description,
		Image:         input.Image,
		Available:     input.Available,
		BaseUnitPrice: input.BaseUnitPrice,
		Options:       input.Options,
	}
	if err := u.menuRepo.CreateItem(item); err != nil {
		return nil, apperror.Wrap(err, "repo creates menu item")
	}

	for _, catID := range input.Categories {
		if err := u.menuRepo.AssociateItemToCategory(item.ID, catID); err != nil {
			return nil, apperror.Wrapf(err, "repo adds item '%d' to category '%d'", item.ID, catID)
		}
	}

	return item, nil
}
