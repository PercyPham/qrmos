package config

import (
	"fmt"
	"os"
	"strconv"
)

// Load retrieves configs from environment variables,
// panics if those are not set properly.
//
// Call this function as close as possible to the start of your program (ideally in main)
func Load() {
	loadAppConfig()
	loadMySQLConfig()
	loadMoMoConfig()

	hasConfigLoaded = true
}

var hasConfigLoaded = false

// ensureConfigLoaded will panic if config has not been loaded yet.
func ensureConfigLoaded() {
	if !hasConfigLoaded {
		panic("config.Load() has not been called, make sure to call it " +
			"as close as possible to the start of your program (ideally in main)")
	}
}

// getENV returns the environment variable with matching key,
// panics if not found.
func getENV(key string) string {
	env := os.Getenv(key)
	if env == "" {
		panic(fmt.Sprintf("Expected env with key '%s', found none", key))
	}
	return env
}

// getIntENV returns the interger environment variable with matching key,
// panics if not found or found non integer number.
func getIntENV(key string) int {
	env := getENV(key)
	envInt, err := strconv.Atoi(env)
	if err != nil {
		panic(fmt.Sprintf("Expected env with key '%s' to be integer, found '%s'", key, env))
	}
	return envInt
}
