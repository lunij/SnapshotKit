DERIVED_DATA_PATH = .derivedData
SNAPSHOT_ARTIFACTS_PATH = /tmp/__SnapshotArtifacts__
TEST_RESULTS = "$(DERIVED_DATA_PATH)/TestResults"

xcodeproj:
	PF_DEVELOP=1 swift run xcodegen

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.4 \
		bash -c 'swift test'

test-macos:
	set -o pipefail && \
		xcodebuild test \
		-scheme SnapshotTesting_macOS \
		-destination platform="macOS" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(TEST_RESULTS) \
		| xcbeautify

test-ios:
	set -o pipefail && \
		xcodebuild test \
		-scheme SnapshotTesting_iOS \
		-destination platform="iOS Simulator,name=iPhone 11 Pro Max,OS=13.3" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(TEST_RESULTS) \
		| xcbeautify

test-tvos:
	set -o pipefail && \
		xcodebuild test \
		-scheme SnapshotTesting_tvOS \
		-destination platform="tvOS Simulator,name=Apple TV 4K,OS=13.3" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(TEST_RESULTS) \
		| xcbeautify

test-apple-platforms: test-macos test-ios test-tvos

snapshots_zip:
	pushd $(SNAPSHOT_ARTIFACTS_PATH); zip -r snapshots * > /dev/null; popd
	mv $(SNAPSHOT_ARTIFACTS_PATH)/snapshots.zip .

clean:
	rm -rf $(DERIVED_DATA_PATH)
	rm -rf *.xcodeproj
	rm -rf .build
