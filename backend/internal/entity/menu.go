package entity

type MenuCategory struct {
	ID          int    `json:"id" grom:"primaryKey"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

type MenuAssociation struct {
	ItemID     int `json:"itemId"`
	CategoryID int `json:"catId" gorm:"column:cat_id"`
}

type MenuItem struct {
	ID            int               `json:"id"`
	Name          string            `json:"name"`
	Description   string            `json:"description"`
	Image         string            `json:"image"`
	Available     bool              `json:"available"`
	BaseUnitPrice int64             `json:"baseUnitPrice"`
	Options       []*MenuItemOption `json:"options"`
}

type MenuItemOption struct {
	Name      string                  `json:"name"`
	Available bool                    `json:"available"`
	MinChoice int                     `json:"minChoice"`
	MaxChoice int                     `json:"maxChoice"`
	Choices   []*MenuItemOptionChoice `json:"choices"`
}

type MenuItemOptionChoice struct {
	Name      string `json:"name"`
	Price     int64  `json:"price"`
	Available bool   `json:"available"`
}
