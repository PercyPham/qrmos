package entity

type MenuCategory struct {
	ID          int    `json:"id" grom:"primaryKey"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

type MenuAssociation struct {
	CatID  int `json:"catID"`
	ItemID int `json:"itemID"`
}

type MenuItem struct {
	ID            int               `json:"id"`
	Name          string            `json:"name"`
	Description   string            `json:"description"`
	Image         string            `json:"image"`
	Available     bool              `json:"available"`
	BaseUnitPrice int               `json:"baseUnitPrice"`
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
	Price     int    `json:"price"`
	Available bool   `json:"available"`
}
