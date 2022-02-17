package menu_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewGetItemUsecase(mr repo.Menu) *GetItemUsecase {
	return &GetItemUsecase{mr}
}

type GetItemUsecase struct {
	menuRepo repo.Menu
}

func (u *GetItemUsecase) GetItemByID(itemID int) (*entity.MenuItem, error) {
	item := u.menuRepo.GetItemByID(itemID)
	if item == nil {
		return nil, apperror.New("item not found").WithCode(http.StatusNotFound)
	}
	return item, nil
}
