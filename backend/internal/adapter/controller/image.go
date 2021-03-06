package controller

import (
	"io"
	"net/http"
	"os"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *server) uploadImage(c *gin.Context) {
	if _, err := s.authCheck.IsManager(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	file, _, err := c.Request.FormFile("image")
	if err != nil {
		appErr := apperror.Wrap(err, "get image from form key 'image' from request").WithCode(http.StatusBadRequest)
		appErr = appErr.WithPublicMessage(appErr.Error())
		response.Error(c, appErr)
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

func (s *server) deleteImage(c *gin.Context) {
	if _, err := s.authCheck.IsManager(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}
	imgName := c.Param("imgName")
	_ = os.Remove("./images/" + imgName)
	response.Success(c, true)
}
