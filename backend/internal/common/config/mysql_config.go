package config

func MySQL() mysqlConfig {
	ensureConfigLoaded()
	return mysql
}

var mysql mysqlConfig

type mysqlConfig struct {
	DSN string
}

func loadMySQLConfig() {
	mysql = mysqlConfig{
		DSN: getENV("MYSQL_DB_CONNECTION_LINK"),
	}
}
