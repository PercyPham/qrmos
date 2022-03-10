package controller

func (s *server) setupAPIs() {
	api := s.r.Group("/api")

	api.GET("/health", s.checkHealth)

	api.POST("/users", s.createUser)
	api.GET("/users", s.getAllUsers)
	api.GET("users/:username", s.getUser)
	api.PUT("users/:username", s.updateUser)

	api.POST("/login", s.login)

	api.POST("/customers", s.createCustomer)
	api.PUT("/customers/me", s.updateCustomer)

	api.GET("/delivery-destinations", s.getAllDests)
	api.GET("/delivery-destinations/:name", s.getDestByName)
	api.POST("/delivery-destinations", s.createDeliveryDest)
	api.PUT("/delivery-destinations/:name/security-code/refresh", s.refreshDeliveryDestSecurityCode)
	api.DELETE("/delivery-destinations/:name", s.deleteDeliveryDest)

	api.GET("/menu", s.getMenu)

	api.POST("/menu/categories", s.createMenuCat)
	api.DELETE("/menu/categories/:catID", s.deleteMenuCat)

	api.POST("/menu/items", s.createMenuItem)
	api.GET("/menu/items/:itemID", s.getMenuItem)
	api.PUT("/menu/items/:itemID", s.updateMenuItem)
	api.PUT("/menu/items/:itemID/available", s.updateItemAvail)
	api.PUT("/menu/items/:itemID/options/:optName/available", s.updateItemOptionAvail)
	api.PUT("/menu/items/:itemID/options/:optName/choices/:choiceName/available", s.updateItemOptionChoiceAvail)
	api.DELETE("/menu/items/:itemID", s.deleteMenuItem)

	api.POST("/menu/categories/:catID/items/:itemID", s.createMenuAssociation)
	api.DELETE("/menu/categories/:catID/items/:itemID", s.deleteMenuAssociation)

	api.GET("/vouchers", s.getVouchers)
	api.POST("/vouchers", s.createVoucher)
	api.DELETE("/vouchers/:code", s.deleteVoucher)

	api.POST("/orders", s.createOrder)
	api.GET("/orders/:orderID", s.getOrder)
	api.GET("/orders/:orderID/logs", s.getOrderLogs)
	api.PATCH("/orders/:orderID/cancel", s.cancelOrder)
	api.PATCH("/orders/:orderID/ready", s.markOrderAsReady)
	api.PATCH("/orders/:orderID/delivered", s.markOrderAsDelivered)
	api.PATCH("/orders/:orderID/delivery-destination/:destName", s.changeOrderDeliveryDest)
	api.PATCH("/orders/:orderID/payment/cash", s.markOrderAsPaidByCash)
	api.PATCH("/orders/:orderID/failed", s.markOrderAsFailed)

	api.POST("/orders/:orderID/payment/momo/payment-link", s.createMoMoPaymentLink)
	api.POST("/orders/:orderID/payment/momo/ipn-callback", s.handleMoMoIpnCallback)
	api.GET("/orders/:orderID/payment/momo/payment-callback", s.handleMoMoPaymentCallback)

	api.GET("/store-configs/opening-hours", s.getStoreOpeningHoursConfig)
	api.PUT("/store-configs/opening-hours", s.updateStoreOpeningHoursConfig)
}
