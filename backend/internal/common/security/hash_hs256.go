package security

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
)

// HashHS256 returns hashed result of HMAC-SHA256 algorithm applied
// on given data and secret key.
func HashHS256(data, secret string) string {
	h := hmac.New(sha256.New, []byte(secret))
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}
