package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/voucher_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) createVoucher(c *gin.Context) {
	now := time.Now()
	if err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(voucher_usecase.CreateVoucherInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	createVoucherUsecase := voucher_usecase.NewCreateVoucherUsecase(s.voucherRepo)
	if err := createVoucherUsecase.Create(body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates voucher"))
		return
	}

	response.Success(c, true)
}
