package config

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"qrmos/internal/common/apperror"
)

func MoMo() momoConfig {
	ensureConfigLoaded()
	return momo
}

var momo momoConfig

type momoConfig struct {
	PartnerCode string

	AccessKey string
	SecretKey string

	PublicKey *rsa.PublicKey

	Domain string
}

func loadMoMoConfig() {
	momo = momoConfig{
		PartnerCode: getENV("MOMO_PARTNER_CODE"),
		AccessKey:   getENV("MOMO_ACCESS_KEY"),
		SecretKey:   getENV("MOMO_SECRET_KEY"),
		Domain:      getENV("MOMO_DOMAIN"),
	}

	pubKey, err := parseRSAPublicKey(getENV("MOMO_PUBLIC_KEY"))
	if err != nil {
		panic(apperror.Wrap(err, "parse env MOMO_PUBLIC_KEY"))
	}

	momo.PublicKey = pubKey
}

func parseRSAPublicKey(pubKeyRaw string) (*rsa.PublicKey, error) {
	var pubKeyData = []byte(fmt.Sprintf(`
-----BEGIN PUBLIC KEY-----
%s
-----END PUBLIC KEY-----
`, pubKeyRaw))

	block, _ := pem.Decode([]byte(pubKeyData))
	if block == nil {
		return nil, apperror.New("failed to parse PEM block containing the public key")
	}
	pkixPub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, apperror.Wrap(err, "failed to parse DER encoded public key")
	}

	publicKey, ok := pkixPub.(*rsa.PublicKey)
	if !ok {
		return nil, apperror.New("cannot cast public key to *rsa.PublicKey")
	}

	return publicKey, nil
}
