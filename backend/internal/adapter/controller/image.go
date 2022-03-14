package controller

import (
	"io"
	"os"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *server) uploadImage(c *gin.Context) {
	file, _, err := c.Request.FormFile("image")
	if err != nil {
		response.Error(c, apperror.Wrap(err, "get file from request"))
		return
	}

	filename := uuid.New().String()

	if _, err := os.Stat("./images"); os.IsNotExist(err) {
		if err := os.MkdirAll("./images", 0755); err != nil {
			response.Error(c, apperror.Wrap(err, "create images folder"))
		}
	}

	out, err := os.Create("./images/" + filename)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "os create file"))
		return
	}
	defer out.Close()

	_, err = io.Copy(out, file)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "io copy file"))
		return
	}

	response.Success(c, gin.H{"imageRelativePath": "/images/" + filename})
}
