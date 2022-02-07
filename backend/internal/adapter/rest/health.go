package rest

import "github.com/gin-gonic/gin"

func (s *server) checkHealth(c *gin.Context) {
	// TODO: check DB connection
	c.JSON(200, gin.H{
		"message": "OK",
	})
}
