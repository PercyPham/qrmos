package repo

import "qrmos/internal/entity"

type Menu interface {
	CreateCategory(*entity.MenuCategory) error
	GetCategoryByName(name string) *entity.MenuCategory
	DeleteCategoryByID(id int) error

	CreateItem(*entity.MenuItem) error
	GetItemByName(name string) *entity.MenuItem

	// AddItemToCategory(itemID, catID string) error
	// RemoveItemFromCategory(itemID, catID string) error
}
