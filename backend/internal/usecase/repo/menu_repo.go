package repo

import "qrmos/internal/entity"

type Menu interface {
	CreateCategory(*entity.MenuCategory) error
	GetCategoryByName(name string) *entity.MenuCategory
	// CreateItem(*entity.MenuItem) error
	// AddItemToCategory(itemID, catID string) error
	// RemoveItemFromCategory(itemID, catID string) error
}
