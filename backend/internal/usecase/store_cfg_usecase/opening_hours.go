package store_cfg_usecase

import (
	"encoding/json"
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
)

func GetOpeningHoursCfg(scr repo.StoreConfig) (*entity.StoreConfigOpeningHours, error) {
	openingHoursUsecase := NewOpeningHoursConfigUsecase(scr)
	openingHours, err := openingHoursUsecase.Get()
	if err != nil {
		return nil, apperror.Wrap(err, "usecase gets opening hours config")
	}
	return openingHours, nil
}

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

type UpdateStoreOpeningHoursCfgInput struct {
	IsManual     bool                    `json:"isManual"`
	IsManualOpen bool                    `json:"isManualOpen"`
	Start        *entity.StoreConfigTime `json:"start"`
	End          *entity.StoreConfigTime `json:"end"`
}

func (i *UpdateStoreOpeningHoursCfgInput) validate() (
	*entity.StoreConfigOpeningHours,
	error) {
	if i.Start == nil {
		return nil, apperror.New("start time must be provided")
	}
	if i.End == nil {
		return nil, apperror.New("end time must be provided")
	}
	start, err := entity.NewStoreConfigTime(i.Start.Hour, i.Start.Minute, i.Start.Second)
	if err != nil {
		return nil, apperror.Wrap(err, "instantiate start time")
	}
	end, err := entity.NewStoreConfigTime(i.End.Hour, i.End.Minute, i.End.Second)
	if err != nil {
		return nil, apperror.Wrap(err, "instantiate end time")
	}
	cfg, err := entity.NewOpeningHours(start, end)
	if err != nil {
		return nil, apperror.Wrap(err, "instantiate store opening hours config")
	}
	cfg.IsManual = i.IsManual
	cfg.IsManualOpen = i.IsManualOpen
	return cfg, nil
}

func (u *OpeningHoursCfgUsecase) Update(input *UpdateStoreOpeningHoursCfgInput) error {
	openingHoursCfg, err := input.validate()
	if err != nil {
		return apperror.Wrap(err, "validate input").WithCode(http.StatusBadRequest)
	}
	cfgJson, _ := json.Marshal(openingHoursCfg)
	storeCfg := &entity.StoreConfig{
		Key:   entity.StoreCfgKeyOpeningHours,
		Value: string(cfgJson),
	}
	if err := u.storeConfigRepo.Update(storeCfg); err != nil {
		return apperror.Wrap(err, "repo updates store opening hours config")
	}
	return nil
}
