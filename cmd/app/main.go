package main

import (
	"log"
	"time"

	"github.com/jeh727/sampleapp/internal/app"
)

func main() {
	address := "0.0.0.0:8080"
	log.Printf("starting server on %s", address)

	err := app.RunServer(address, 3*time.Second)
	if err != nil {
		log.Printf("server exiting with error: %v", err)
	}
}
