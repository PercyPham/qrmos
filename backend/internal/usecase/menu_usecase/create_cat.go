package menu_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewCreateCategoryUsecase(mr repo.Menu) *CreateCategoryUsecase {
	return &CreateCategoryUsecase{mr}
}

type CreateCategoryUsecase struct {
	menuRepo repo.Menu
}

type CreateCategoryInput struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func (i *CreateCategoryInput) validate() error {
	if i.Name == "" {
		return apperror.New("name must be provided")
	}
	return nil
}

func (u *CreateCategoryUsecase) Create(input *CreateCategoryInput) (*entity.MenuCategory, error) {
	if err := input.validate(); err != nil {
		return nil, apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(apperror.RootCause(err).Error())
	}

	cat := u.menuRepo.GetCategoryByName(input.Name)
	if cat != nil {
		return nil, apperror.New("category already exists")
	}

	cat = &entity.MenuCategory{
		Name:        input.Name,
		Description: input.Description,
	}
	if err := u.menuRepo.CreateCategory(cat); err != nil {
		return nil, apperror.Wrap(err, "repo create menu category")
	}

	return cat, nil
}
