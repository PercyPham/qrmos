package security

import (
	"math/rand"
	"strings"
	"time"
)

var charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

// GenRanStr returns a random string with specified length.
func GenRanStr(t time.Time, length int) string {
	source := rand.NewSource(t.UnixNano())
	r := rand.New(source)

	var randomStr strings.Builder
	for i := 0; i < length; i++ {
		random := r.Intn(len(charSet))
		randomChar := charSet[random]
		randomStr.WriteString(string(randomChar))
	}

	return randomStr.String()
}
