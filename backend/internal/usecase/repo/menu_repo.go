package repo

import "qrmos/internal/entity"

type Menu interface {
	CreateCategory(*entity.MenuCategory) error
	GetAllCategories() ([]*entity.MenuCategory, error)
	GetCategoryByName(name string) *entity.MenuCategory
	GetCategoryByID(catID int) *entity.MenuCategory
	DeleteCategoryByID(id int) error

	CreateItem(*entity.MenuItem) error
	GetAllItems() ([]*entity.MenuItem, error)
	GetItemsByIDs(ids []int) ([]*entity.MenuItem, error)
	GetItemByID(id int) *entity.MenuItem
	GetItemByName(name string) *entity.MenuItem
	UpdateItem(item *entity.MenuItem) error
	DeleteItemByID(id int) error

	CreateAssociation(*entity.MenuAssociation) error
	CheckIfAssociationExists(*entity.MenuAssociation) bool
	GetAllAssociations() ([]*entity.MenuAssociation, error)
	DeleteAssociation(*entity.MenuAssociation) error
}
