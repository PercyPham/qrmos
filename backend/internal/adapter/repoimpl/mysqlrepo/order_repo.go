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
	CreatorType         string
	CreatorStaff        string
	CreatorCus          string
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

	creator := &entity.OrderCreator{
		Type:          g.CreatorType,
		StaffUsername: g.CreatorStaff,
		CustomerID:    g.CreatorCus,
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

	if order.Creator == nil {
		order.Creator = &entity.OrderCreator{}
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
		CreatorType:         order.Creator.Type,
		CreatorStaff:        order.Creator.StaffUsername,
		CreatorCus:          order.Creator.CustomerID,
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

func (r *orderRepo) GetOrders(filter *repo.GetOrdersFilter) ([]*entity.Order, int, error) {
	gOrders := []*gormOrder{}

	tx := r.txAppliedFilter(filter)

	offset := filter.ItemPerPage * (filter.Page - 1)
	limit := filter.ItemPerPage
	result := tx.Offset(offset).Limit(limit).Find(&gOrders)
	if result.Error != nil {
		return nil, 0, apperror.Wrap(result.Error, "gorm gets orders")
	}

	orders := make([]*entity.Order, len(gOrders))
	orderIDs := make([]int, len(orders))
	var err error
	for i, gOrder := range gOrders {
		orders[i], err = gOrder.toOrder()
		if err != nil {
			return nil, 0, apperror.Wrap(err, "convert gOrder to Order")
		}
		orderIDs[i] = gOrder.ID
	}

	gOrderItems := []*gormOrderItem{}
	orderItemsResult := r.db.Table("order_items").Where("order_id IN ?", orderIDs).Find(&gOrderItems)
	if orderItemsResult.Error != nil {
		return nil, 0, apperror.Wrap(orderItemsResult.Error, "gorm gets orders' items")
	}

	m := map[int][]*entity.OrderItem{}
	for _, gOrderItem := range gOrderItems {
		if m[gOrderItem.OrderID] == nil {
			m[gOrderItem.OrderID] = []*entity.OrderItem{}
		}
		orderItem, err := gOrderItem.toOrderItem()
		if err != nil {
			return nil, 0, apperror.Wrap(err, "convert gorm order item")
		}
		m[gOrderItem.OrderID] = append(m[gOrderItem.OrderID], orderItem)
	}
	for _, order := range orders {
		order.OrderItems = m[order.ID]
	}

	tx = r.txAppliedFilter(filter)

	var total int64 = 0
	countResult := tx.Count(&total)
	if countResult.Error != nil {
		return nil, 0, apperror.Wrap(countResult.Error, "gorm counts orders")
	}

	return orders, int(total), nil
}

func (r *orderRepo) txAppliedFilter(filter *repo.GetOrdersFilter) *gorm.DB {
	tx := r.db.Table("orders")
	if filter.CustomerID != "" {
		tx = tx.Where("creator_cus = ?", filter.CustomerID)
	}
	if filter.State != "" {
		tx = tx.Where("state = ?", filter.State)
	}

	sortCreatedAt := "desc"
	if filter.SortCreatedAt != "" {
		sortCreatedAt = filter.SortCreatedAt
	}
	tx.Order("created_at " + sortCreatedAt)

	if filter.CreatedAtFrom != nil {
		tx.Where("created_at >= ?", *filter.CreatedAtFrom)
	}
	if filter.CreatedAtTo != nil {
		tx.Where("created_at <= ?", *filter.CreatedAtTo)
	}

	return tx
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

func (r *orderRepo) Update(order *entity.Order) error {
	gOrder, err := convertToGormOrder(order)
	if err != nil {
		return apperror.Wrap(err, "convert to gorm order")
	}
	result := r.db.Table("orders").Save(gOrder)
	if result.Error != nil {
		return apperror.Wrap(result.Error, "gorm db save order")
	}
	return nil
}
