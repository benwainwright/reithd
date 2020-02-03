.PHONY: build release
SRC_FILES=$(find . -name "*.swift")

.build/debug/reithd: ${SRC_FILES}
	@swift build
	@echo "Built to .build/debug/reithd"

.build/release/reithd: ${SRC_FILES}
	@swift build -c release
	@echo "Built to .build/release/reithd"

build: .build/debug/reithd

release: .build/release/reithd
	./scripts/release.sh .build/release/reithd


