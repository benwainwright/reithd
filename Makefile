SRC_FILES=$(find . -name "*.swift")

.build/debug/reithd: ${SRC_FILES}
	swift build

.build/release/reithd: ${SRC_FILES}
	swift build -c release


