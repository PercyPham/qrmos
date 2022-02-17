package repo

import "qrmos/internal/entity"

type Menu interface {
	CreateCategory(*entity.MenuCategory) error
	GetCategoryByName(name string) *entity.MenuCategory
	GetCategoryByID(catID int) *entity.MenuCategory
	DeleteCategoryByID(id int) error

	CreateItem(*entity.MenuItem) error
	GetItemByID(id int) *entity.MenuItem
	GetItemByName(name string) *entity.MenuItem
	UpdateItem(item *entity.MenuItem) error

	AddItemToCategory(itemID, catID int) error
	RemoveItemFromCategory(itemID, catID int) error
	GetAllCatIDsOfItem(itemID int) (catIDs []int, err error)
}
