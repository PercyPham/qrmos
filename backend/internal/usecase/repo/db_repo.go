package repo

type DB interface {
	Ping() error
}
