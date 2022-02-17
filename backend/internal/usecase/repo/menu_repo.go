package repo

import "qrmos/internal/entity"

type Menu interface {
	CreateCategory(*entity.MenuCategory) error
	GetCategoryByName(name string) *entity.MenuCategory
	GetCategoryByID(catID int) *entity.MenuCategory
	DeleteCategoryByID(id int) error

	CreateItem(*entity.MenuItem) error
	GetItemByName(name string) *entity.MenuItem

	AddItemToCategory(itemID, catID int) error
	RemoveItemFromCategory(itemID, catID int) error
}
