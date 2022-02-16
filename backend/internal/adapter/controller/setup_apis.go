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
}
