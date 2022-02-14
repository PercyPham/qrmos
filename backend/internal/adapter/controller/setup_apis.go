package controller

func (s *server) setupAPIs() {
	api := s.r.Group("/api")

	api.GET("/health", s.checkHealth)
	api.GET("/users", s.getAllUsers)
	api.POST("/login", s.login)
}
