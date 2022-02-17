package mysqlrepo

import (
	"encoding/json"
	"fmt"
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

func (r *menuRepo) GetCategoryByID(catID int) *entity.MenuCategory {
	cat := new(entity.MenuCategory)
	result := r.db.Where("id = ?", catID).First(cat)
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

type gormMenuItem struct {
	ID            int    `json:"id" gorm:"primaryKey"`
	Name          string `json:"name"`
	Description   string `json:"description"`
	Image         string `json:"image"`
	Available     bool   `json:"available"`
	BaseUnitPrice int    `json:"baseUnitPrice"`
	Options       []byte `json:"options"`
}

func (i *gormMenuItem) toMenuItem() (*entity.MenuItem, error) {
	options := []*entity.MenuItemOption{}
	if i.Options != nil {
		err := json.Unmarshal(i.Options, &options)
		if err != nil {
			return nil, apperror.Wrap(err, "json unmarshal item options")
		}
	}

	return &entity.MenuItem{
		ID:            i.ID,
		Name:          i.Name,
		Description:   i.Description,
		Image:         i.Image,
		Available:     i.Available,
		BaseUnitPrice: i.BaseUnitPrice,
		Options:       options,
	}, nil
}

func convertToGormMenuItem(i *entity.MenuItem) (*gormMenuItem, error) {
	var options []byte
	if i.Options != nil {
		optionsJson, err := json.Marshal(i.Options)
		if err != nil {
			return nil, apperror.Wrap(err, "json marshal item options")
		}
		options = optionsJson
	}
	return &gormMenuItem{
		ID:            i.ID,
		Name:          i.Name,
		Description:   i.Description,
		Image:         i.Image,
		Available:     i.Available,
		BaseUnitPrice: i.BaseUnitPrice,
		Options:       options,
	}, nil
}

func (r *menuRepo) CreateItem(item *entity.MenuItem) error {
	gItem, err := convertToGormMenuItem(item)
	if err != nil {
		return apperror.Wrap(err, "convert to gorm menu item")
	}
	result := r.db.Table("menu_items").Create(gItem)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates menu item")
	}
	item.ID = gItem.ID
	return nil
}

func (r *menuRepo) GetItemByID(itemID int) *entity.MenuItem {
	gItem := new(gormMenuItem)
	result := r.db.Table("menu_items").Where("id = ?", itemID).First(gItem)
	if result.Error != nil {
		return nil
	}
	item, err := gItem.toMenuItem()
	if err != nil {
		fmt.Println(err)
	}
	return item
}

func (r *menuRepo) GetItemByName(name string) *entity.MenuItem {
	gItem := new(gormMenuItem)
	result := r.db.Table("menu_items").Where("name = ?", name).First(gItem)
	if result.Error != nil {
		return nil
	}
	item, err := gItem.toMenuItem()
	if err != nil {
		fmt.Println(err)
	}
	return item
}

func (r *menuRepo) UpdateItem(item *entity.MenuItem) error {
	gItem, err := convertToGormMenuItem(item)
	if err != nil {
		return apperror.Wrap(err, "convert to gorm menu item")
	}
	result := r.db.Table("menu_items").Save(gItem)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm db updates menu item")
	}
	return nil
}

type gormCatItem struct {
	CategoryID int `gorm:"column:cat"`
	ItemID     int `gorm:"column:item"`
}

func (r *menuRepo) AddItemToCategory(itemID, catID int) error {
	gCatItem := &gormCatItem{
		CategoryID: catID,
		ItemID:     itemID,
	}
	result := r.db.Table("cat_items").Create(gCatItem)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates cat item")
	}
	return nil
}

func (r *menuRepo) RemoveItemFromCategory(itemID, catID int) error {
	result := r.db.Table("cat_items").Where("cat = ? AND item = ?", catID, itemID).Delete(gormCatItem{})
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm deletes association between cat '%d' and item '%d'", catID, itemID)
	}
	return nil
}

func (r *menuRepo) GetAllCatIDsOfItem(itemID int) ([]int, error) {
	gCatItems := []gormCatItem{}
	result := r.db.Table("cat_items").Where("item = ?", itemID).Find(&gCatItems)
	if result.Error != nil {
		return nil, apperror.Wrapf(result.Error, "gorm gets associations of item '%d'", itemID)
	}
	catIDs := []int{}
	for _, catItem := range gCatItems {
		catIDs = append(catIDs, catItem.CategoryID)
	}
	return catIDs, nil
}
