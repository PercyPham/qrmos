package controller

import (
	"qrmos/internal/adapter/controller/internal/response"
	"qrmos/internal/common/apperror"
	"qrmos/internal/usecase/customer_usecase"

	"github.com/gin-gonic/gin"
)

func (s *server) createCustomer(c *gin.Context) {
	body := new(customer_usecase.CreateCustomerInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}

	createCustomerUsecase := customer_usecase.NewCreateCustomerUsecase()
	customerAccessToken, err := createCustomerUsecase.CreateCustomer(body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates customer"))
		return
	}

	response.Success(c, gin.H{
		"accessToken": customerAccessToken,
	})
}
