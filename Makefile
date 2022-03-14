DERIVED_DATA_PATH = .derivedData
SNAPSHOT_ARTIFACTS_PATH = /tmp/__SnapshotArtifacts__
TEST_RESULTS_IOS = "$(DERIVED_DATA_PATH)/TestResults_iOS"
TEST_RESULTS_MACOS = "$(DERIVED_DATA_PATH)/TestResults_macOS"
TEST_RESULTS_TVOS = "$(DERIVED_DATA_PATH)/TestResults_tvOS"

lint:
	swiftformat --swiftversion 5.5 --cache ignore --lint .
	swiftlint --strict

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
		-scheme SnapshotKit \
		-destination platform="macOS" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(TEST_RESULTS_MACOS) \
		-workspace . \
		| xcbeautify

test-ios:
	set -o pipefail && \
		xcodebuild test \
		-scheme SnapshotKit \
		-destination platform="iOS Simulator,name=iPhone 12,OS=latest" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(TEST_RESULTS_IOS) \
		-workspace . \
		| xcbeautify

test-tvos:
	set -o pipefail && \
		xcodebuild test \
		-scheme SnapshotKit \
		-destination platform="tvOS Simulator,name=Apple TV 4K,OS=latest" \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath $(TEST_RESULTS_TVOS) \
		-workspace . \
		| xcbeautify

test-apple-platforms: test-macos test-ios test-tvos

snapshots_zip:
	pushd $(SNAPSHOT_ARTIFACTS_PATH); zip -r snapshots * > /dev/null; popd
	mv $(SNAPSHOT_ARTIFACTS_PATH)/snapshots.zip .

xcresults_zip:
	pushd $(DERIVED_DATA_PATH); zip -r xcresults *.xcresult > /dev/null; popd
	mv $(DERIVED_DATA_PATH)/xcresults.zip .

clean:
	rm -rf $(DERIVED_DATA_PATH)
	rm -rf *.xcodeproj
	rm -rf .build
