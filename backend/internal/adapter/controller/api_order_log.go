package controller

import (
	"fmt"
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/entity"
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

func (s *server) logOrderActionByCus(cus *entity.Customer, t time.Time, orderID int, action, extra string) {
	orderLogUsecase := order_log_usecase.NewOrderLogUsecase(s.orderLogRepo)
	if err := orderLogUsecase.LogActionByCus(cus, t, orderID, action, extra); err != nil {
		s.printOrderLogErr(apperror.Wrap(err, "log order action by customer"))
	}
}

func (s *server) logOrderActionByStaff(staff *entity.User, t time.Time, orderID int, action, extra string) {
	orderLogUsecase := order_log_usecase.NewOrderLogUsecase(s.orderLogRepo)
	if err := orderLogUsecase.LogActionByStaff(staff, t, orderID, action, extra); err != nil {
		s.printOrderLogErr(apperror.Wrap(err, "log order action by staff"))
	}
}

func (s *server) printOrderLogErr(err apperror.AppError) {
	errMsg := fmt.Sprintf("[Warning] [OrderLog] %v", err)
	redStrFormat := "\033[1;38;2;252;172;6m%s\033[0m"
	errMsg = fmt.Sprintf(redStrFormat, errMsg)
	fmt.Println(errMsg)
}
