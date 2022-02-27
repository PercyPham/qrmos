package store_cfg_usecase

import (
	"encoding/json"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func NewOpeningHoursConfigUsecase(scr repo.StoreConfig) *OpeningHoursCfgUsecase {
	return &OpeningHoursCfgUsecase{scr}
}

type OpeningHoursCfgUsecase struct {
	storeConfigRepo repo.StoreConfig
}

func (u *OpeningHoursCfgUsecase) Init() error {
	start, _ := entity.NewStoreConfigTime(8, 0, 0)
	end, _ := entity.NewStoreConfigTime(22, 0, 0)
	openingHours, _ := entity.NewOpeningHours(start, end)
	openingHoursJson, _ := json.Marshal(openingHours)
	openingHoursCfg := &entity.StoreConfig{
		Key:   entity.StoreCfgKeyOpeningHours,
		Value: string(openingHoursJson),
	}
	if err := u.storeConfigRepo.Upsert(openingHoursCfg); err != nil {
		return apperror.Wrap(err, "repo upsert store opening hours config")
	}
	return nil
}

func (u *OpeningHoursCfgUsecase) Get() (*entity.StoreConfigOpeningHours, error) {
	cfg := u.storeConfigRepo.GetByKey(entity.StoreCfgKeyOpeningHours)
	if cfg == nil {
		return nil, apperror.New("opening hours config missing")
	}
	openingHours := new(entity.StoreConfigOpeningHours)
	if err := json.Unmarshal([]byte(cfg.Value), openingHours); err != nil {
		return nil, apperror.Wrap(err, "unmarshal opening hours config")
	}
	return openingHours, nil
}

func (u *OpeningHoursCfgUsecase) Update(cfg *entity.StoreConfigOpeningHours) error {
	cfgJson, _ := json.Marshal(cfg)
	storeCfg := &entity.StoreConfig{
		Key:   entity.StoreCfgKeyOpeningHours,
		Value: string(cfgJson),
	}
	if err := u.storeConfigRepo.Update(storeCfg); err != nil {
		return apperror.Wrap(err, "repo updates store opening hours config")
	}
	return nil
}
