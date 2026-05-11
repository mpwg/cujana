.PHONY: architecture-check lint secret-check test

architecture-check:
	./scripts/check_architecture.sh
	./scripts/check_secret_leaks.sh
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "SwiftLint not installed; skipped SwiftLint. CI will enforce it."; \
	fi

secret-check:
	./scripts/check_secret_leaks.sh

lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "SwiftLint not installed."; \
		exit 1; \
	fi

test:
	./scripts/run_xcode_tests.sh
