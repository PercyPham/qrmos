package order_usecase

import (
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
	"qrmos/internal/usecase/repo"
	"qrmos/internal/usecase/store_cfg_usecase"
	"time"
)

func NewCreateOrderUsecase(
	or repo.Order,
	mr repo.Menu,
	dr repo.Delivery,
	vr repo.Voucher,
	scr repo.StoreConfig,
) *CreateOrderUsecase {
	return &CreateOrderUsecase{or, mr, dr, vr, scr}
}

type CreateOrderUsecase struct {
	orderRepo       repo.Order
	menuRepo        repo.Menu
	deliveryRepo    repo.Delivery
	voucherRepo     repo.Voucher
	storeConfigRepo repo.StoreConfig
}

type CreateOrderInput struct {
	Creator                  *entity.OrderCreator
	CustomerName             string                  `json:"customerName"`
	CustomerPhone            string                  `json:"customerPhone"`
	DeliveryDest             string                  `json:"deliveryDest"`
	DeliveryDestSecurityCode string                  `json:"deliveryDestSecurityCode"`
	Items                    []*CreateOrderItemInput `json:"items"`
	Voucher                  string                  `json:"voucher"`
}

func (i *CreateOrderInput) validate() error {
	if i.Creator == nil {
		return apperror.New("creator must be provided")
	}
	if err := i.Creator.Validate(); err != nil {
		return apperror.Wrap(err, "validate creator")
	}
	if i.CustomerName == "" {
		return apperror.New("customerName must be provided")
	}
	if i.CustomerPhone == "" {
		return apperror.New("customerPhone must be provided")
	}
	if i.DeliveryDest == "" {
		return apperror.New("deliveryDest must be provided")
	}
	if i.DeliveryDestSecurityCode == "" {
		return apperror.New("deliveryDestSecurityCode must be provided")
	}
	if i.Items == nil || len(i.Items) == 0 {
		return apperror.New("items must be provided")
	}
	for i, item := range i.Items {
		if err := item.validate(); err != nil {
			return apperror.Wrapf(err, "validate item at index '%d'", i)
		}
	}
	return nil
}

type CreateOrderItemInput struct {
	ItemID   int    `json:"itemId"`
	Quantity int    `json:"quantity"`
	Note     string `json:"note,omitempty"`

	/// Options is a map of {optionName : [choice]}
	Options map[string][]string `json:"options"`
}

func (i *CreateOrderItemInput) validate() error {
	if i.Quantity < 1 {
		return apperror.New("quantity must be greater than 0")
	}
	if i.Options == nil {
		return nil
	}
	for optionName, choices := range i.Options {
		if optionName == "" {
			return apperror.New("option name must not be empty")
		}
		uniqueChoices := map[string]bool{}
		for _, choice := range choices {
			if choice == "" {
				return apperror.New("option choice must not be empty")
			}
			if uniqueChoices[choice] {
				return apperror.New("option choices must not contain duplicates")
			}
			uniqueChoices[choice] = true
		}
	}
	return nil
}

func (u *CreateOrderUsecase) Create(t time.Time, input *CreateOrderInput) (*entity.Order, error) {
	if err := input.validate(); err != nil {
		return nil, apperror.Wrap(err, "validate input").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(err.Error())
	}

	if err := u.validateCreationTime(t); err != nil {
		return nil, apperror.Wrap(err, "validate creation time")
	}

	if err := u.validateDeliveryDest(input.DeliveryDest, input.DeliveryDestSecurityCode); err != nil {
		return nil, apperror.Wrap(err, "validate delivery destination").WithCode(http.StatusBadRequest)
	}

	voucher := new(entity.Voucher)
	if input.Voucher != "" {
		voucher = u.voucherRepo.GetByCode(input.Voucher)
		if voucher == nil {
			return nil, apperror.New("voucher not found").WithCode(http.StatusBadRequest)
		}
		if voucher.IsUsed {
			return nil, apperror.New("voucher is used already").WithCode(http.StatusBadRequest)
		}
	}

	menuItems, err := u.getAllMenuItemsFrom(input.Items)
	if err != nil {
		return nil, apperror.Wrap(err, "get menu items")
	}

	total, orderItems, err := u.calculateOrderItems(menuItems, input.Items)
	if err != nil {
		return nil, apperror.Wrap(err, "calculate order items").
			WithCode(http.StatusBadRequest).
			WithPublicMessage(err.Error())
	}

	total -= voucher.Discount
	if total < 0 {
		total = 0
	}

	order := &entity.Order{
		State:               entity.OrderStatePending,
		CustomerName:        input.CustomerName,
		CustomerPhone:       input.CustomerPhone,
		DeliveryDestination: input.DeliveryDest,
		Voucher:             voucher.Code,
		Discount:            voucher.Discount,
		Total:               total,
		OrderItems:          orderItems,
		Creator:             input.Creator,
		CreatedAt:           t,
	}

	if voucher.Code != "" {
		voucher.IsUsed = true
		if err := u.voucherRepo.Update(voucher); err != nil {
			return nil, apperror.Wrap(err, "repo updates voucher")
		}
	}

	if err := u.orderRepo.Create(order); err != nil {
		return nil, apperror.Wrap(err, "repo creates order")
	}

	return order, nil
}

func (u *CreateOrderUsecase) validateCreationTime(t time.Time) error {
	openingHours, err := store_cfg_usecase.GetOpeningHoursCfg(u.storeConfigRepo)
	if err != nil {
		return apperror.Wrap(err, "repo get store opening hours config")
	}
	if !openingHours.IsInOpeningHours(t) {
		return apperror.New("not in opening hours").WithCode(http.StatusBadRequest)
	}
	return nil
}

func (u *CreateOrderUsecase) validateDeliveryDest(destName, destSecurityCode string) error {
	deliveryDest := u.deliveryRepo.GetByName(destName)
	if deliveryDest == nil {
		return apperror.New("delivery destination not found")
	}
	if deliveryDest.SecurityCode != destSecurityCode {
		return apperror.New("invalid delivery destination security code")
	}
	return nil
}

func (u *CreateOrderUsecase) getAllMenuItemsFrom(
	inputItems []*CreateOrderItemInput,
) (map[int]*entity.MenuItem, error) {
	menuItems := make(map[int]*entity.MenuItem)
	for _, inputItem := range inputItems {
		if _, ok := menuItems[inputItem.ItemID]; ok {
			continue
		}
		menuItem := u.menuRepo.GetItemByID(inputItem.ItemID)
		if menuItem == nil {
			return nil, apperror.Newf("item with id '%d' not found", inputItem.ItemID).
				WithCode(http.StatusNotFound)
		}
		menuItems[inputItem.ItemID] = menuItem
	}
	return menuItems, nil
}

func (u *CreateOrderUsecase) calculateOrderItems(
	menuItems map[int]*entity.MenuItem,
	inputItems []*CreateOrderItemInput,
) (total int64, orderItems []*entity.OrderItem, err error) {
	total = 0
	orderItems = make([]*entity.OrderItem, len(inputItems))

	for i, inputItem := range inputItems {
		menuItem := menuItems[inputItem.ItemID]
		if !menuItem.Available {
			return 0, nil, apperror.Newf("item with id '%d' is not available", inputItem.ItemID)
		}
		unitPrice, options, err := u.calculateOrderItem(menuItem, inputItem)
		if err != nil {
			return 0, nil, apperror.Wrapf(err, "calculate order item at index '%d'", i)
		}
		orderItem := &entity.OrderItem{
			Name:      menuItem.Name,
			UnitPrice: unitPrice,
			Quantity:  inputItem.Quantity,
			Note:      inputItem.Note,
			Options:   options,
		}
		orderItems[i] = orderItem
		total += int64(orderItem.Quantity) * orderItem.UnitPrice
	}
	return total, orderItems, nil
}

func (u *CreateOrderUsecase) calculateOrderItem(
	menuItem *entity.MenuItem,
	inputItem *CreateOrderItemInput,
) (unitPrice int64, options map[string][]string, err error) {
	unitPrice = menuItem.BaseUnitPrice
	options = map[string][]string{}

	for optName, opt := range menuItem.Options {
		if !opt.Available {
			continue
		}
		cusChoices := inputItem.Options[optName]
		cusChoiceCount := 0
		if cusChoices != nil {
			cusChoiceCount = len(cusChoices)
		}
		if cusChoiceCount < opt.MinChoice || cusChoiceCount > opt.MaxChoice {
			return 0, nil, apperror.Newf("not enough choices for option '%s' of item '%d'", optName, inputItem.ItemID)
		}
	}

	for optionName, choices := range inputItem.Options {
		if len(choices) == 0 {
			delete(inputItem.Options, optionName)
		}
	}

	for optionName, choices := range inputItem.Options {
		menuOption, ok := menuItem.Options[optionName]
		if !ok {
			return 0, nil, apperror.Newf("option '%s' of item '%d' not found", optionName, inputItem.ItemID)
		}
		if !menuOption.Available {
			return 0, nil, apperror.Newf("menu option '%s' of item '%d' is not available", optionName, inputItem.ItemID)
		}
		if menuOption.MinChoice > len(choices) ||
			menuOption.MaxChoice < len(choices) {
			return 0, nil, apperror.Newf("invalid number of choices for option '%s' of item '%d'", optionName, inputItem.ItemID)
		}
		for _, choiceName := range choices {
			choice, ok := menuOption.Choices[choiceName]
			if !ok {
				return 0, nil, apperror.Newf("option choice '%s' of option '%s' of item '%d' not found", choiceName, optionName, inputItem.ItemID)
			}
			if !choice.Available {
				return 0, nil, apperror.Newf("option choice '%s' of option '%s' of item '%d' is not available", choiceName, optionName, inputItem.ItemID)
			}
			unitPrice += choice.Price
		}
		options[optionName] = choices
	}

	return unitPrice, options, nil
}
