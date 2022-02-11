package response

import (
	"fmt"
	"net/http"
	"qrmos/internal/common/apperror"

	"github.com/gin-gonic/gin"
)

func Error(c *gin.Context, err error) {
	appErr := apperror.Wrap(apperror.Wrap(err, getReqInfo(c)), "api")
	logError(appErr)
	response(c, newErrorResponse(appErr.Code(), appErr.PublicMessage()))
}

func getReqInfo(c *gin.Context) string {
	reqInfo := c.Request.Method + " " + c.Request.URL.Path
	if c.Request.URL.RawQuery != "" {
		reqInfo += "?" + c.Request.URL.RawQuery
	}
	return reqInfo
}

func newErrorResponse(code int, message string) errorResponse {
	errContent := errorContent{code, message}
	return errorResponse{errContent}
}

type errorResponse struct {
	Error errorContent `json:"error"`
}

type errorContent struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func logError(err apperror.AppError) {
	errMsg := fmt.Sprintf("[Error] [%d] %v", err.Code(), err)
	redStrFormat := "\033[1;31m%s\033[0m"
	errMsg = fmt.Sprintf(redStrFormat, errMsg)
	fmt.Println(errMsg)
}

func Success(c *gin.Context, data interface{}) {
	payload := successResponse{data}
	response(c, payload)
}

type successResponse struct {
	Data interface{} `json:"data"`
}

func response(c *gin.Context, payload interface{}) {
	c.JSON(http.StatusOK, payload)
}
