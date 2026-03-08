package app_test

import (
	"context"
	"net/http/httptest"
	"testing"

	"github.com/jeh727/sampleapp/internal/app"
	"gotest.tools/v3/golden"
)

func TestHello(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name   string
		code   int
		golden string
	}{
		{name: "Happy Path", code: 200, golden: "hello.golden"},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			t.Parallel()

			req := httptest.NewRequestWithContext(context.Background(), "GET", "/", nil)
			rec := httptest.NewRecorder()

			app.Hello(rec, req)

			code := rec.Code
			if code != testCase.code {
				t.Fatalf("expected status code %d, got %d", testCase.code, code)
			}

			res := rec.Body.String()
			golden.Assert(t, res, testCase.golden)
		})
	}
}
