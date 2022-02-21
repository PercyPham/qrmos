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

func (r *menuRepo) GetAllCategories() ([]*entity.MenuCategory, error) {
	cats := []*entity.MenuCategory{}
	result := r.db.Find(&cats)
	if result.Error != nil {
		return nil, apperror.Wrapf(result.Error, "gorm gets all categories")
	}
	return cats, nil
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
	BaseUnitPrice int64  `json:"baseUnitPrice"`
	Options       []byte `json:"options"`
}

func (i *gormMenuItem) toMenuItem() (*entity.MenuItem, error) {
	options := map[string]*entity.MenuItemOption{}
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

func (r *menuRepo) GetAllItems() ([]*entity.MenuItem, error) {
	gItems := []gormMenuItem{}
	result := r.db.Table("menu_items").Find(&gItems)
	if result.Error != nil {
		return nil, apperror.Wrapf(result.Error, "gorm gets all items")
	}
	items := []*entity.MenuItem{}
	for _, gItem := range gItems {
		item, err := gItem.toMenuItem()
		if err != nil {
			return nil, apperror.Wrap(err, "gorm convert gItem to menu item")
		}
		items = append(items, item)
	}
	return items, nil
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

func (r *menuRepo) DeleteItemByID(id int) error {
	result := r.db.Table("menu_items").Where("id = ?", id).Delete(gormMenuItem{})
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm db delete menu item")
	}
	return nil
}

func (r *menuRepo) CreateAssociation(association *entity.MenuAssociation) error {
	result := r.db.Create(association)
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm creates association between cat '%d' and item '%d'", association.CategoryID, association.ItemID)
	}
	return nil
}

func (r *menuRepo) CheckIfAssociationExists(association *entity.MenuAssociation) bool {
	foundAssociation := new(entity.MenuAssociation)
	result := r.db.
		Where("item_id = ? AND cat_id = ?", association.ItemID, association.CategoryID).
		First(foundAssociation)
	return result.Error == nil
}

func (r *menuRepo) DeleteAssociation(association *entity.MenuAssociation) error {
	result := r.db.
		Where("item_id = ? AND cat_id = ?", association.ItemID, association.CategoryID).
		Delete(association)
	if result.Error != nil {
		return apperror.Wrapf(result.Error, "gorm deletes association between cat '%d' and item '%d'", association.CategoryID, association.ItemID)
	}
	return nil
}

func (r *menuRepo) GetAllAssociations() ([]*entity.MenuAssociation, error) {
	gCatItems := []*entity.MenuAssociation{}
	result := r.db.Find(&gCatItems)
	if result.Error != nil {
		return nil, apperror.Wrapf(result.Error, "gorm gets all associations")
	}
	associations := []*entity.MenuAssociation{}
	for _, catItem := range gCatItems {
		associations = append(associations, &entity.MenuAssociation{
			CategoryID: catItem.CategoryID,
			ItemID:     catItem.ItemID,
		})
	}
	return associations, nil
}
