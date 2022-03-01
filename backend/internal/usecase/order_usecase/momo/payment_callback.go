package momo

import (
	"bytes"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/common/security"
	"strconv"
)

type PaymentCallbackData struct {
	Amount       int64  `json:"amount"`
	ExtraData    string `json:"extraData"`
	Message      string `json:"message"`
	OrderID      string `json:"orderId"`
	OrderInfo    string `json:"orderInfo"`
	OrderType    string `json:"orderType"`
	PartnerCode  string `json:"partnerCode"`
	PayType      string `json:"payType"`
	RequestID    string `json:"requestId"`
	ResponseTime int64  `json:"responseTime"`
	ResultCode   int64  `json:"resultCode"`
	Signature    string `json:"signature"`
	TransID      int64  `json:"transId"`
}

func (data *PaymentCallbackData) Verify() error {
	if data.ResultCode != 0 {
		return apperror.New("result is not success")
	}
	if data.Signature != data.sign() {
		return apperror.New("invalid signature")
	}
	return nil
}

func (data *PaymentCallbackData) sign() string {
	var rawSignature bytes.Buffer

	rawSignature.WriteString("accessKey=" + config.MoMo().AccessKey)
	rawSignature.WriteString("&amount=" + strconv.FormatInt(data.Amount, 10))
	rawSignature.WriteString("&extraData=" + data.ExtraData)
	rawSignature.WriteString("&message=" + data.Message)
	rawSignature.WriteString("&orderId=" + data.OrderID)
	rawSignature.WriteString("&orderInfo=" + data.OrderInfo)
	rawSignature.WriteString("&orderType=" + data.OrderType)
	rawSignature.WriteString("&partnerCode=" + data.PartnerCode)
	rawSignature.WriteString("&payType=" + data.PayType)
	rawSignature.WriteString("&requestId=" + data.RequestID)
	rawSignature.WriteString("&responseTime=" + strconv.FormatInt(data.ResponseTime, 10))
	rawSignature.WriteString("&resultCode=" + strconv.FormatInt(data.ResultCode, 10))
	rawSignature.WriteString("&transId=" + strconv.FormatInt(data.TransID, 10))

	return security.HashHS256(rawSignature.String(), config.MoMo().SecretKey)
}

// GetQrmosOrderID returns the order ID of QRMOS system which is specified in extra data, not OrderID in ipn request
func (data *PaymentCallbackData) GetQrmosOrderID() (int, error) {
	orderIDStr := data.ExtraData
	orderID, err := strconv.ParseInt(orderIDStr, 10, 32)
	if err != nil {
		return 0, apperror.Wrap(err, "parse orderID from extra data")
	}
	return int(orderID), nil
}
