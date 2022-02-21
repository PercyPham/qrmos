package menu_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewAssociationUsecase(mr repo.Menu) *AssociationUsecase {
	return &AssociationUsecase{mr}
}

type AssociationUsecase struct {
	menuRepo repo.Menu
}

func (u *AssociationUsecase) AssociateItemToCategory(itemID, catID int) error {
	item := u.menuRepo.GetItemByID(itemID)
	if item == nil {
		return apperror.New("item not found").WithCode(http.StatusNotFound)
	}
	cat := u.menuRepo.GetCategoryByID(catID)
	if cat == nil {
		return apperror.New("category not found").WithCode(http.StatusNotFound)
	}
	association := &entity.MenuAssociation{
		ItemID:     itemID,
		CategoryID: catID,
	}
	if u.menuRepo.CheckIfAssociationExists(association) {
		return nil
	}
	if err := u.menuRepo.CreateAssociation(association); err != nil {
		return apperror.Wrap(err, "repo creates association")
	}
	return nil
}

func (u *AssociationUsecase) DisassociateItemFromCategory(itemID, catID int) error {
	association := &entity.MenuAssociation{
		ItemID:     itemID,
		CategoryID: catID,
	}
	if err := u.menuRepo.DeleteAssociation(association); err != nil {
		return apperror.Wrap(err, "repo creates association")
	}
	return nil
}
