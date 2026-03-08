package app

import (
	"fmt"
	"net/http"
	"time"
)

func RunServer(address string, readHeaderTimeout time.Duration) error {
	http.HandleFunc("/", Hello)

	server := &http.Server{
		Addr:              address,
		ReadHeaderTimeout: readHeaderTimeout,
	}

	err := server.ListenAndServe()
	if err != nil {
		return fmt.Errorf("server failed\n%w", err)
	}

	return nil
}
