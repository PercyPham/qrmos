package entity

import (
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"time"
)

type StoreConfig struct {
	Key   string `json:"key" gorm:"column:cfg_key;primaryKey"`
	Value string `json:"value" gorm:"column:cfg_val"`
}

const StoreCfgKeyOpeningHours = "opening_hours"

func NewOpeningHours(start *StoreConfigTime, end *StoreConfigTime) (*StoreConfigOpeningHours, error) {
	if start.Compare(end) >= 0 {
		return nil, apperror.New("start time must be smaller than end time")
	}
	return &StoreConfigOpeningHours{
		IsManual: false, IsManualOpen: false,
		Start: start, End: end,
	}, nil
}

type StoreConfigOpeningHours struct {
	// IsManual is a flag that indicates whether the store is open manually or automatically.
	IsManual bool `json:"isManual"`
	// IsManualOpen is a flag that indicates whether if the opening time is manually managed to open or not.
	IsManualOpen bool `json:"isManualOpen"`

	Start *StoreConfigTime `json:"start"`
	End   *StoreConfigTime `json:"end"`
}

func (c *StoreConfigOpeningHours) IsInOpeningHours(t time.Time) bool {
	if c.IsManual && c.IsManualOpen {
		return true
	}

	t = t.In(config.App().TimeLocation)
	cmp, _ := NewStoreConfigTime(t.Hour(), t.Minute(), t.Second())
	if cmp.Compare(c.Start) >= 0 && cmp.Compare(c.End) < 0 {
		return true
	}

	return false
}

func NewStoreConfigTime(hour, min, sec int) (*StoreConfigTime, error) {
	if hour < 0 || hour > 24 {
		return nil, apperror.Newf("invalid hour '%d'", hour)
	}
	if min < 0 || min > 60 {
		return nil, apperror.Newf("invalid minute '%d'", min)
	}
	if sec < 0 || sec > 60 {
		return nil, apperror.Newf("invalid second '%d'", sec)
	}
	if hour == 24 && (min != 0 || sec != 0) {
		return nil, apperror.Newf("invalid time '%d:%d:%d'", hour, min, sec)
	}
	return &StoreConfigTime{hour, min, sec}, nil
}

type StoreConfigTime struct {
	Hour   int `json:"hour"`
	Minute int `json:"min"`
	Second int `json:"sec"`
}

// Compare returns 0 if times are equal, 1 if the other time is smaller and -1 otherwise.
func (t *StoreConfigTime) Compare(other *StoreConfigTime) int {
	if t.Hour != other.Hour {
		return t.compare(t.Hour, other.Hour)
	}
	if t.Minute != other.Minute {
		return t.compare(t.Minute, other.Minute)
	}
	if t.Second != other.Second {
		return t.compare(t.Second, other.Second)
	}
	return 0
}

func (t *StoreConfigTime) compare(a, b int) int {
	if a > b {
		return 1
	}
	if a < b {
		return -1
	}
	return 0
}
