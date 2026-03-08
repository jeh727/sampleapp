package app_test

import (
	"net/http/httptest"
	"testing"

	"github.com/jeh727/sampleapp/internal/app"
	"gotest.tools/v3/golden"
)

//var update = flag.Bool("update", false, "update golden files")

func TestHello(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name   string
		code   int
		golden string
	}{
		{name: "Happy Path", code: 200, golden: "hello.golden"},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			req := httptest.NewRequest("GET", "/", nil)
			w := httptest.NewRecorder()

			app.Hello(w, req)

			code := w.Code
			if code != tc.code {
				t.Fatalf("expected status code %d, got %d", tc.code, code)
			}

			res := w.Body.String()
			golden.Assert(t, res, tc.golden)
		})
	}
}
