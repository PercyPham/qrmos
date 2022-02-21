package controller

func (s *server) setupAPIs() {
	api := s.r.Group("/api")

	api.GET("/health", s.checkHealth)

	api.POST("/users", s.createUser)
	api.GET("/users", s.getAllUsers)
	api.PUT("users/:username", s.updateUser)

	api.POST("/login", s.login)

	api.POST("/customers", s.createCustomer)
	api.PUT("/customers/me", s.updateCustomer)

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

	api.POST("/vouchers", s.createVoucher)
	api.DELETE("/vouchers/:code", s.deleteVoucher)
}
