package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/order_log_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) getOrderLogs(c *gin.Context) {
	if _, err := s.authCheck.IsStaff(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	orderID, err := getIntParam(c, "orderID")
	if err != nil {
		response.Error(c, err)
		return
	}

	getOrderLogsUsecase := order_log_usecase.NewOrderLogUsecase(s.orderLogRepo)
	logs, err := getOrderLogsUsecase.GetLogsOfOrder(orderID)
	if err != nil {
		response.Error(c, apperror.Wrapf(err, "usecase gets logs of order '%d", orderID))
		return
	}

	response.Success(c, logs)
}
