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

func (s *server) updateCustomer(c *gin.Context) {
	customer, err := s.authCheck.IsCustomer(c)
	if err != nil {
		response.Error(c, newUnauthorizedError(err))
		return
	}

	body := new(customer_usecase.UpdateCustomerInput)
	if err := c.ShouldBindJSON(body); err != nil {
		response.Error(c, newBindJsonReqBodyError(err))
		return
	}
	body.CustomerID = customer.ID

	updateCustomerUsecase := customer_usecase.NewUpdateCustomerUsecase()
	newCustomerAccessToken, err := updateCustomerUsecase.UpdateCustomer(body)
	if err != nil {
		response.Error(c, apperror.Wrap(err, "usecase creates customer"))
		return
	}

	response.Success(c, gin.H{
		"accessToken": newCustomerAccessToken,
	})
}
