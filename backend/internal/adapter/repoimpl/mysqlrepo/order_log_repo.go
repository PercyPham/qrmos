package mysqlrepo

import (
	"encoding/json"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"time"

	"gorm.io/gorm"
)

func NewOrderLogRepo(db *gorm.DB) repo.OrderLog {
	return &orderLogRepo{db}
}

type orderLogRepo struct {
	db *gorm.DB
}

type gormOrderLog struct {
	OrderID   int `gorm:"column:order_id"`
	Action    string
	Actor     string
	Extra     string
	CreatedAt int64
}

func convertToGormOrderLog(orderLog *entity.OrderLog) (*gormOrderLog, error) {
	actorJson, err := json.Marshal(orderLog.Actor)
	if err != nil {
		return nil, apperror.Wrap(err, "marshal order log actor")
	}
	return &gormOrderLog{
		OrderID:   orderLog.OrderID,
		Action:    orderLog.Action,
		Actor:     string(actorJson),
		Extra:     orderLog.Extra,
		CreatedAt: orderLog.CreatedAt.UnixNano(),
	}, nil
}

func (g *gormOrderLog) toOrderLog() (*entity.OrderLog, error) {
	actor := new(entity.OrderLogActor)
	if err := json.Unmarshal([]byte(g.Actor), actor); err != nil {
		return nil, apperror.Wrap(err, "unmarshal order log actor")
	}

	return &entity.OrderLog{
		OrderID:   g.OrderID,
		Action:    g.Action,
		Actor:     actor,
		Extra:     g.Extra,
		CreatedAt: time.Unix(0, g.CreatedAt),
	}, nil
}

func (r *orderLogRepo) Create(orderLog *entity.OrderLog) error {
	gOrderLog, err := convertToGormOrderLog(orderLog)
	if err != nil {
		return apperror.Wrap(err, "convert to gorm order log")
	}
	result := r.db.Table("order_logs").Create(gOrderLog)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm creates order log")
	}
	return nil
}

func (r *orderLogRepo) GetAllByOrderID(orderID int) ([]*entity.OrderLog, error) {
	gLogs := []*gormOrderLog{}
	result := r.db.Table("order_logs").Where("order_id = ?", orderID).Find(&gLogs)
	if result.Error != nil {
		return nil, apperror.Wrapf(result.Error, "gorm gets all order logs")
	}
	logs := make([]*entity.OrderLog, len(gLogs))
	for i, gLog := range gLogs {
		log, err := gLog.toOrderLog()
		if err != nil {
			return nil, apperror.Wrapf(err, "gorm convert order log")
		}
		logs[i] = log
	}
	return logs, nil
}
