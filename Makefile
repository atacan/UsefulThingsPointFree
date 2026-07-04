.PHONY: all build build-macos build-ios clean test help

DOCKER_IMAGE := swift:latest

# Default target - build for both platforms
all: build

# Build for both platforms
build: build-macos build-ios
	@echo "✓ Successfully built for all platforms"

# Build for macOS
build-macos:
	@echo "Building for macOS..."
	@swift build

# Build for iOS
build-ios:
	@echo "Building for iOS..."
	@xcodebuild build -scheme UsefulThings -destination 'generic/platform=iOS' | grep -E "(Build succeeded|error:|note:)" || true

# Run tests (macOS only, as tests typically run on macOS)
test:
	@echo "Running tests..."
	@swift test

build-linux: ## Run swift tests inside a Docker container
	docker run --rm \
		-v "$(CURDIR):/code" \
		-w /code \
		$(DOCKER_IMAGE) \
		swift build

test-on-linux: ## Run swift tests inside a Docker container
	docker run --rm \
		-v "$(CURDIR):/code" \
		-w /code \
		$(DOCKER_IMAGE) \
		swift test

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@swift package clean
	@rm -rf .swiftpm/xcode
	@rm -rf .build
	@echo "✓ Clean complete"

# Show help
help:
	@echo "Available targets:"
	@echo "  make all        - Build for both macOS and iOS (default)"
	@echo "  make build      - Build for both macOS and iOS"
	@echo "  make build-macos - Build for macOS only"
	@echo "  make build-ios  - Build for iOS only"
	@echo "  make test       - Run tests"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make help       - Show this help message"

check_uncommitted:
	@if git diff-index --quiet HEAD --; then \
		echo '\033[32mNo uncommitted changes found.\033[0m'; \
	else \
		echo '\033[31mUncommitted changes detected. Aborting.\033[0m'; \
		exit 1; \
	fi

# merge the current branch to main and push
merge_main: check_uncommitted
	# get the name of the current branch
	$(eval BRANCH := $(shell git branch --show-current))
	# merge the current branch to main
	git checkout main
	git merge $(BRANCH)
	git push