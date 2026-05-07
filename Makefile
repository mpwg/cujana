.PHONY: architecture-check lint test

architecture-check:
	./scripts/check_architecture.sh
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "SwiftLint not installed; skipped SwiftLint. CI will enforce it."; \
	fi

lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "SwiftLint not installed."; \
		exit 1; \
	fi

test:
	./scripts/run_xcode_tests.sh
