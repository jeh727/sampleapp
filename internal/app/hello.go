package app

import (
	"fmt"
	"net/http"
)

func Hello(w http.ResponseWriter, _ *http.Request) {
	fmt.Fprintln(w, "Hello world!")
}
