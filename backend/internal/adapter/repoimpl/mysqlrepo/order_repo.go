package mysqlrepo

import (
	"encoding/json"
	"fmt"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"time"

	"gorm.io/gorm"
)

func NewOrderRepo(db *gorm.DB) repo.Order {
	return &orderRepo{db}
}

type orderRepo struct {
	db *gorm.DB
}

type gormOrder struct {
	ID                  int
	State               string
	CustomerName        string `gorm:"column:cus_name"`
	CustomerPhone       string `gorm:"column:cus_phone"`
	DeliveryDestination string `gorm:"column:deliver_dest"`
	Voucher             string
	Discount            int64
	Total               int64
	Payment             string
	FailReason          string `gorm:"column:fail_reason"`
	Creator             string
	CreatedAt           int64 `gorm:"column:created_at"`
}

func (g *gormOrder) toOrder() (*entity.Order, error) {
	var err error
	var payment *entity.OrderPayment
	if g.Payment != "" {
		err = json.Unmarshal([]byte(g.Payment), &payment)
		if err != nil {
			return nil, apperror.Wrap(err, "unmarshal payment")
		}
	}

	creator := new(entity.OrderCreator)
	if g.Creator != "" {
		err = json.Unmarshal([]byte(g.Creator), creator)
		if err != nil {
			return nil, apperror.Wrap(err, "unmarshal creator")
		}
	}

	return &entity.Order{
		ID:                  g.ID,
		State:               g.State,
		CustomerName:        g.CustomerName,
		CustomerPhone:       g.CustomerPhone,
		DeliveryDestination: g.DeliveryDestination,
		Voucher:             g.Voucher,
		Discount:            g.Discount,
		Total:               g.Total,
		Payment:             payment,
		FailReason:          g.FailReason,
		Creator:             creator,
		CreatedAt:           time.Unix(0, g.CreatedAt),
	}, nil
}

func convertToGormOrder(order *entity.Order) (*gormOrder, error) {
	var err error

	var payment []byte
	if order.Payment != nil {
		payment, err = json.Marshal(order.Payment)
		if err != nil {
			return nil, apperror.Wrap(err, "marshal payment")
		}
	}

	var creator []byte
	if order.Creator != nil {
		creator, err = json.Marshal(order.Creator)
		if err != nil {
			return nil, apperror.Wrap(err, "marshal creator")
		}
	}

	gOrder := &gormOrder{
		ID:                  order.ID,
		State:               order.State,
		CustomerName:        order.CustomerName,
		CustomerPhone:       order.CustomerPhone,
		DeliveryDestination: order.DeliveryDestination,
		Voucher:             order.Voucher,
		Discount:            order.Discount,
		Total:               order.Total,
		Payment:             string(payment),
		FailReason:          order.FailReason,
		Creator:             string(creator),
		CreatedAt:           order.CreatedAt.UnixNano(),
	}
	return gOrder, nil
}

type gormOrderItem struct {
	OrderID   int `gorm:"column:order_id"`
	Name      string
	UnitPrice int64 `gorm:"column:unit_price"`
	Quantity  int
	Note      string
	Options   string
}

func (g *gormOrderItem) toOrderItem() (*entity.OrderItem, error) {
	var err error
	var options map[string][]string
	if g.Options != "" {
		err = json.Unmarshal([]byte(g.Options), &options)
		if err != nil {
			return nil, apperror.Wrap(err, "unmarshal options")
		}
	}

	return &entity.OrderItem{
		Name:      g.Name,
		UnitPrice: g.UnitPrice,
		Quantity:  g.Quantity,
		Note:      g.Note,
		Options:   options,
	}, nil
}

func convertToGormOrderItem(orderID int, orderItem *entity.OrderItem) (*gormOrderItem, error) {
	var err error

	var options []byte
	if orderItem.Options != nil {
		options, err = json.Marshal(orderItem.Options)
		if err != nil {
			return nil, apperror.Wrap(err, "marshal order item options")
		}
	}

	return &gormOrderItem{
		OrderID:   orderID,
		Name:      orderItem.Name,
		UnitPrice: orderItem.UnitPrice,
		Quantity:  orderItem.Quantity,
		Note:      orderItem.Note,
		Options:   string(options),
	}, nil
}

func (r *orderRepo) Create(order *entity.Order) error {
	gOrder, err := convertToGormOrder(order)
	if err != nil {
		return apperror.Wrap(err, "convert to gorm order")
	}

	tx := r.db.Begin()

	result := tx.Table("orders").Create(gOrder)
	if result.Error != nil {
		tx.Rollback()
		return apperror.Wrap(result.Error, "gorm create order")
	}

	gOrderItems := make([]*gormOrderItem, len(order.OrderItems))
	for i, orderItem := range order.OrderItems {
		gOrderItems[i], err = convertToGormOrderItem(gOrder.ID, orderItem)
		if err != nil {
			tx.Rollback()
			return apperror.Wrap(err, "convert to gorm order item")
		}
	}

	result = tx.Table("order_items").CreateInBatches(gOrderItems, len(order.OrderItems))
	if result.Error != nil {
		tx.Rollback()
		return apperror.Wrap(result.Error, "gorm create order items")
	}

	order.ID = gOrder.ID
	tx.Commit()
	return nil
}

func (r *orderRepo) GetByID(id int) *entity.Order {
	gOrder := new(gormOrder)
	result := r.db.Table("orders").Where("id = ?", id).First(gOrder)
	if result.Error != nil {
		return nil
	}
	order, err := gOrder.toOrder()
	if err != nil {
		fmt.Println(err)
		return nil
	}

	gOrderItems := []*gormOrderItem{}
	result = r.db.Table("order_items").Where("order_id = ?", id).Find(&gOrderItems)
	if result.Error != nil {
		fmt.Println(err)
		return nil
	}
	orderItems := []*entity.OrderItem{}
	for _, gOrderItem := range gOrderItems {
		orderItem, err := gOrderItem.toOrderItem()
		if err != nil {
			return nil
		}
		orderItems = append(orderItems, orderItem)
	}
	order.OrderItems = orderItems

	return order
}
