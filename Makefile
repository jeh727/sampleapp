# Makefile for Go project
GO ?= go

PROJECT_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CMD_DIR := $(PROJECT_ROOT)/cmd
BIN_DIR := $(PROJECT_ROOT)/bin
TOOLS_DIR := $(PROJECT_ROOT)/tools
SCRIPTS_DIR := $(PROJECT_ROOT)/scripts
ALL_GO_FILES := $(PROJECT_ROOT)/...

PROGS := $(shell for d in $(CMD_DIR)/*; do [ -d $$d ] && basename $$d || true; done)
BINARIES := $(addprefix $(BIN_DIR)/,$(PROGS))

.PHONY: all build test golden cover fmt vet tidy install run hooks hook-msg linter clean setup lint help gofumpt
all: build

## build: Build all binaries in the cmd directory
build: fmt lint test clean compile
	@echo "Build complete. Binaries are located in the $(BIN_DIR) directory."

compile: $(BINARIES)

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(BIN_DIR)/%: $(BIN_DIR)
	$(GO) build -o $@ $(CMD_DIR)/$*

## setup: Install git hooks, linters and other necessary tools for development
setup: hooks linter $(TOOLS_DIR)/golangci-lint $(TOOLS_DIR)/gofumpt
	@echo "Project setup complete. Git hooks and linters installed."

hooks: hook-msg .git/hooks/commit-msg
	

hook-msg:
	@echo "Installing git hooks..." 

.git/hooks/commit-msg:
	@curl -L https://cdn.rawgit.com/tommarshall/git-good-commit/v0.6.1/hook.sh > .git/hooks/commit-msg && chmod +x .git/hooks/commit-msg

## linter: Install golangci-lint
linter: $(TOOLS_DIR)/golangci-lint

$(TOOLS_DIR)/golangci-lint:
	@echo "Installing golangci-lint..."
	@mkdir -p $(TOOLS_DIR)
	@curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(TOOLS_DIR) v2.11.1



## test: Run all tests in the project
test:
	$(GO) test -count=1 -cover $(ALL_GO_FILES)

## golden: update all test golden files
golden:
	$(GO) test $(ALL_GO_FILES) -update

## cover: Generate test coverage report
cover: $(BIN_DIR)
	$(GO) test -coverprofile=$(BIN_DIR)/coverage.out $(ALL_GO_FILES)
	$(GO) tool cover -html=$(BIN_DIR)/coverage.out -o $(BIN_DIR)/coverage.html
	@$(SCRIPTS_DIR)/launch-browser.sh $(BIN_DIR)/coverage.html || true

## fmt: Format all Go files in the project
fmt: gofumpt
	$(GO) fmt $(ALL_GO_FILES)

gofumpt: $(TOOLS_DIR)/gofumpt
	$(TOOLS_DIR)/gofumpt -w -extra .

$(TOOLS_DIR)/gofumpt:
	@echo "Installing gofumpt..."
	@mkdir -p $(TOOLS_DIR)
	@GOBIN=$(TOOLS_DIR) $(GO) install mvdan.cc/gofumpt@latest

## lint: Run golangci-lint on all packages
lint: linter
	$(TOOLS_DIR)/golangci-lint run $(ALL_GO_FILES)

## tidy: Clean up go.mod and go.sum files
tidy:
	$(GO) mod tidy

## install: Install all binaries to the GOPATH/bin
install:
	$(GO) install $(ALL_GO_FILES)

## make run NAME=<program> [ARGS="args..."]: Run a program from the cmd directory with optional arguments
run:
ifndef NAME
	$(error NAME is not set. e.g., make run NAME=yourcmd)
endif
	$(GO) run $(CMD_DIR)/$(NAME) $(ARGS)

## clean: Remove all built binaries
clean:
	rm -rf $(BIN_DIR)


## help: Display this help message
help: Makefile
	@echo
	@echo " Usage: make [target]"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo