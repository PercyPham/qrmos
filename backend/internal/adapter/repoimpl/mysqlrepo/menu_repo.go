package mysqlrepo

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"

	"gorm.io/gorm"
)

func NewMenuRepo(db *gorm.DB) repo.Menu {
	return &menuRepo{db}
}

type menuRepo struct {
	db *gorm.DB
}

func (r *menuRepo) CreateCategory(cat *entity.MenuCategory) error {
	result := r.db.Create(cat)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates menu category")
	}
	return nil
}

func (r *menuRepo) GetCategoryByName(name string) *entity.MenuCategory {
	cat := new(entity.MenuCategory)
	result := r.db.Where("name = ?", name).First(cat)
	if result.Error != nil {
		return nil
	}
	return cat
}

func (r *menuRepo) DeleteCategoryByID(id int) error {
	result := r.db.Where("id = ?", id).Delete(entity.MenuCategory{})
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm db delete menu category")
	}
	return nil
}
