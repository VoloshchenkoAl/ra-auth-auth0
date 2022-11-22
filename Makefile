.PHONY: build help

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: package.json ## install dependencies
	@if [ "$(CI)" != "true" ]; then \
		echo "Full install..."; \
		yarn; \
	fi
	@if [ "$(CI)" = "true" ]; then \
		echo "Frozen install..."; \
		yarn --frozen-lockfile; \
	fi

build-ra-auth-auth0:
	@echo "Transpiling ra-auth-auth0 files...";
	@cd ./packages/ra-auth-auth0 && yarn -s build

build-demo-react-admin:
	@echo "Transpiling demo files...";
	@cd ./packages/demo-react-admin && yarn -s build

build: build-ra-auth-auth0 build-demo-react-admin ## compile ES6 files to JS

lint: ## lint the code and check coding conventions
	@echo "Running linter..."
	@yarn -s lint

prettier: ## prettify the source code using prettier
	@echo "Running prettier..."
	@yarn -s prettier

test: build test-unit lint ## launch all tests

test-unit: ## launch unit tests
	echo "Running unit tests...";
	yarn -s test-unit;

run-demo:
	@cd ./packages/demo-react-admin && yarn start

run: auth0-start

DOCKER_COMPOSE = docker-compose -p ra-auth-auth0 -f ./docker-compose.yml

auth0-start: ## Start the project with docker.
	$(DOCKER_COMPOSE) up --force-recreate -d

auth0-logs: ## Display logs
	$(DOCKER_COMPOSE) logs -f

auth0-stop: ## Stop the project with docker.
	$(DOCKER_COMPOSE) down