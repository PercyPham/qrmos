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

const momoCreatePaymentLinkEndpoint = "/v2/gateway/api/create"

func CreatePaymentLink(orderID int, amount int64) (string, error) {
	payload := newCreatePaymentPayload(orderID, amount)
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return "", apperror.Wrap(err, "marshal create payment payload")
	}

	resp, err := http.Post(
		config.MoMo().Domain+momoCreatePaymentLinkEndpoint,
		"application/json; charset=UTF-8",
		bytes.NewBuffer(jsonPayload))
	if err != nil {
		return "", apperror.Wrap(err, "make POST create payment request to MoMo server")
	}

	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)

	if err := isMoMoResultSuccess(result); err != nil {
		return "", apperror.Wrap(err, "check result success")
	}

	paymentLink, ok := result["payUrl"].(string)
	if !ok {
		return "", apperror.New("cannot retrieve payUrl")
	}

	return paymentLink, nil
}

func newCreatePaymentPayload(orderID int, amount int64) *createPaymentPayload {
	scheme := "http"
	if config.App().ENV == "prod" {
		scheme = "https"
	}
	prefixURL := fmt.Sprintf("%s://%s/api/orders/%d/payment/momo", scheme, config.App().Domains[0], orderID)

	redirectURL := prefixURL + "/payment-callback"
	ipnURL := prefixURL + "/ipn-callback"

	momoReqID := uuid.New().String()
	orderIDStr := fmt.Sprintf("%d", orderID)

	payload := &createPaymentPayload{
		RequestType: "captureWallet",
		PartnerCode: config.MoMo().PartnerCode,
		AutoCapture: true,
		RequestID:   momoReqID,
		OrderID:     momoReqID,
		OrderInfo:   "Payment for Order " + orderIDStr,
		Amount:      amount,
		ExtraData:   orderIDStr,
		RedirectUrl: redirectURL,
		IpnURL:      ipnURL,
		Lang:        "en",
	}
	payload.Signature = payload.sign()

	return payload
}

type createPaymentPayload struct {
	PartnerCode string `json:"partnerCode"`
	RequestID   string `json:"requestId"`
	AutoCapture bool   `json:"autoCapture"`
	Amount      int64  `json:"amount"`
	OrderID     string `json:"orderId"`
	OrderInfo   string `json:"orderInfo"`
	RedirectUrl string `json:"redirectUrl"`
	IpnURL      string `json:"ipnUrl"`
	ExtraData   string `json:"extraData"`
	RequestType string `json:"requestType"`
	Lang        string `json:"lang"`
	Signature   string `json:"signature"`
}

func (p *createPaymentPayload) sign() (signature string) {
	var rawSignature bytes.Buffer

	rawSignature.WriteString("accessKey=" + config.MoMo().AccessKey)
	rawSignature.WriteString("&amount=" + strconv.FormatInt(p.Amount, 10))
	rawSignature.WriteString("&extraData=" + p.ExtraData)
	rawSignature.WriteString("&ipnUrl=" + p.IpnURL)
	rawSignature.WriteString("&orderId=" + p.OrderID)
	rawSignature.WriteString("&orderInfo=" + p.OrderInfo)
	rawSignature.WriteString("&partnerCode=" + p.PartnerCode)
	rawSignature.WriteString("&redirectUrl=" + p.RedirectUrl)
	rawSignature.WriteString("&requestId=" + p.RequestID)
	rawSignature.WriteString("&requestType=" + p.RequestType)

	return security.HashHS256(rawSignature.String(), config.MoMo().SecretKey)
}
