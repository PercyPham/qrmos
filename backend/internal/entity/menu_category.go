package entity

type MenuCategory struct {
	ID          int    `json:"id" grom:"primaryKey"`
	Name        string `json:"name"`
	Description string `json:"description"`
}
