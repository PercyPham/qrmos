package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/voucher_usecase"
	"time"

	"github.com/gin-gonic/gin"
)

func (s *server) getVouchers(c *gin.Context) {
	if _, err := s.authCheck.IsManager(time.Now(), c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}
	getVouchersUsecase := voucher_usecase.NewGetVouchersUsecase(s.voucherRepo)
	vouchers, err := getVouchersUsecase.GetVouchers()
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase gets vouchers"))
		return
	}
	response.Success(c, vouchers)
}

func (s *server) createVoucher(c *gin.Context) {
	now := time.Now()
	manager, err := s.authCheck.IsManager(now, c)
	if err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(voucher_usecase.CreateVoucherInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}
	body.CreatedBy = manager.Username

	createVoucherUsecase := voucher_usecase.NewCreateVoucherUsecase(s.voucherRepo)
	if err := createVoucherUsecase.Create(body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates voucher"))
		return
	}

	response.Success(c, true)
}

func (s *server) deleteVoucher(c *gin.Context) {
	now := time.Now()
	if _, err := s.authCheck.IsManager(now, c); err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(voucher_usecase.DeleteVoucherInput)
	body.Code = c.Param("code")

	deleteVoucherUsecase := voucher_usecase.NewDeleteVoucherUsecase(s.voucherRepo)
	if err := deleteVoucherUsecase.Delete(body); err != nil {
		response.Error(c, apperror.Wrap(err, "usecase deletes voucher"))
		return
	}

	response.Success(c, true)
}
