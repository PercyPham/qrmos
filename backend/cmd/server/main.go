package main

import (
	"qrmos/internal/adapter/rest"
)

func main() {
	server := rest.NewServer()

	server.Run(5000)
}
