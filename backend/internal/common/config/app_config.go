package config

import (
	"fmt"
	"strings"
	"time"
)

func App() appConfig {
	ensureConfigLoaded()
	return app
}

var app appConfig

type appConfig struct {
	ENV          string
	Port         int
	Domains      []string
	Secret       string
	TimeLocation *time.Location
}

func loadAppConfig() {
	app = appConfig{
		ENV:     getENV("APP_ENV"),
		Port:    getIntENV("APP_PORT"),
		Domains: strings.Split(getENV("APP_DOMAINS"), ";"),
		Secret:  getENV("APP_SECRET"),
	}

	appTimeLocation := getENV("APP_TIME_LOCATION")
	timeLocation, err := time.LoadLocation(appTimeLocation)
	if err != nil {
		panic(fmt.Sprintf("Expected valid APP_TIME_LOCATION, got '%s'\nReference: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones", appTimeLocation))
	}
	app.TimeLocation = timeLocation

	if !(app.ENV == "dev" || app.ENV == "staging" || app.ENV == "prod") {
		panic(fmt.Sprintf("Expected env with key 'APP_ENV' to be 'dev' or 'staging' or 'prod', found '%v'", app.ENV))
	}
}
