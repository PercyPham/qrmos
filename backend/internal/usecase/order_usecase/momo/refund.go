package momo

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"qrmos/internal/common/apperror"
	"qrmos/internal/common/config"
	"qrmos/internal/common/security"
	"strconv"

	"github.com/google/uuid"
)

const momoRefundEndpoint = "/v2/gateway/api/refund"

func Refund(paymentRequestID, description string, amount, transID int64) error {
	payload := newRefundPayload(paymentRequestID, description, amount, transID)
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return apperror.Wrap(err, "marshal refund payload")
	}

	resp, err := http.Post(
		config.MoMo().Domain+momoRefundEndpoint,
		"application/json; charset=UTF-8",
		bytes.NewBuffer(jsonPayload))
	if err != nil {
		return apperror.Wrap(err, "make POST refund request to MoMo server")
	}

	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)

	// TODO: for Dev, should remove later
	if config.App().ENV == "dev" {
		jsonResult, _ := json.Marshal(result)
		fmt.Println("Response from Momo: ", string(jsonResult))
	}

	if err := isMoMoResultSuccess(result); err != nil {
		return apperror.Wrap(err, "check result success")
	}

	return nil
}

func newRefundPayload(reqID, description string, amount, transID int64) *refundPayload {
	momoReqID := uuid.New().String()
	p := &refundPayload{
		PartnerCode: config.MoMo().PartnerCode,
		OrderID:     momoReqID,
		RequestID:   momoReqID,
		Amount:      amount,
		TransID:     transID,
		Lang:        "en",
		Description: description,
	}
	p.Signature = p.sign()
	return p
}

type refundPayload struct {
	PartnerCode string `json:"partnerCode"`
	OrderID     string `json:"orderId"`
	RequestID   string `json:"requestId"`
	Amount      int64  `json:"amount"`
	TransID     int64  `json:"transId"`
	Lang        string `json:"lang"`
	Description string `json:"description"`
	Signature   string `json:"signature"`
}

func (p *refundPayload) sign() (signature string) {
	var rawSignature bytes.Buffer

	rawSignature.WriteString("accessKey=" + config.MoMo().AccessKey)
	rawSignature.WriteString("&amount=" + strconv.FormatInt(p.Amount, 10))
	rawSignature.WriteString("&description=" + p.Description)
	rawSignature.WriteString("&orderId=" + p.OrderID)
	rawSignature.WriteString("&partnerCode=" + p.PartnerCode)
	rawSignature.WriteString("&requestId=" + p.RequestID)
	rawSignature.WriteString("&transId=" + strconv.FormatInt(p.TransID, 10))

	return security.HashHS256(rawSignature.String(), config.MoMo().SecretKey)
}
