package menu_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewDeleteCatUsecase(mr repo.Menu) *DeleteCatUsecase {
	return &DeleteCatUsecase{mr}
}

type DeleteCatUsecase struct {
	menuRepo repo.Menu
}

func (u *DeleteCatUsecase) DeleteByID(id int) error {
	if err := u.menuRepo.DeleteCategoryByID(id); err != nil {
		return apperror.Wrap(err, "repo deletes menu category")
	}
	return nil
}
