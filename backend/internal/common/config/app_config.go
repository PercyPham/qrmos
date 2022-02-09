package config

import (
	"fmt"
	"strings"
)

func App() appConfig {
	ensureConfigLoaded()
	return app
}

var app appConfig

type appConfig struct {
	ENV     string
	Port    int
	Domains []string
}

func loadAppConfig() {
	app = appConfig{
		ENV:     getENV("APP_ENV"),
		Port:    getIntENV("APP_PORT"),
		Domains: strings.Split(getENV("APP_DOMAINS"), ";"),
	}

	if !(app.ENV == "dev" || app.ENV == "prod") {
		panic(fmt.Sprintf("Expected env with key 'APP_ENV' to be 'dev' or 'prod', found '%v'", app.ENV))
	}
}
