package momo

import "qrmos/internal/common/apperror"

func isMoMoResultSuccess(result map[string]interface{}) error {
	resultCode, ok := result["resultCode"]
	if !ok {
		return apperror.New("cannot retrieve resultCode")
	}
	if code, ok := resultCode.(float64); !ok || code != 0 {
		return apperror.Newf("expected resultCode to be 0, got %v with message '%v'", resultCode, result["message"])
	}
	return nil
}
