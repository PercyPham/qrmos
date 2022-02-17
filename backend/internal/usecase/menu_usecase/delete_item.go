package menu_usecase

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/repo"
)

func NewDeleteItemUsecase(mr repo.Menu) *DeleteItemUsecase {
	return &DeleteItemUsecase{mr}
}

type DeleteItemUsecase struct {
	menuRepo repo.Menu
}

func (u *DeleteItemUsecase) DeleteByID(id int) error {
	if err := u.menuRepo.DeleteItemByID(id); err != nil {
		return apperror.Wrap(err, "repo deletes menu item")
	}
	return nil
}
