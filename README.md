# 📸 SnapshotKit

[![Swift 5.4](https://img.shields.io/badge/swift-5.1-ED523F.svg?style=flat)](https://swift.org/download/)
[![CI](https://github.com/pointfreeco/swift-snapshot-testing/workflows/CI/badge.svg)](https://actions-badge.atrox.dev/pointfreeco/swift-snapshot-testing/goto)

Delightful Swift snapshot testing.

<!--
![An example of a snapshot failure in Xcode.](.github/snapshot-test-1.png)
-->

## Usage

Once [installed](#installation), _no additional configuration is required_. You can import the `SnapshotKit` module and call the `assertSnapshot` function.

``` swift
import SnapshotKit
import XCTest

class MyViewControllerTests: XCTestCase {
  func testMyViewController() {
    let vc = MyViewController()

    assertSnapshot(matching: vc, as: .image)
  }
}
```

When an assertion first runs, a snapshot is automatically recorded to disk and the test will fail, printing out the file path of any newly-recorded reference.

> 🛑 failed - No reference was found on disk. Automatically recorded snapshot: …
>
> open "…/MyAppTests/\_\_Snapshots\_\_/MyViewControllerTests/testMyViewController.png"
>
> Re-run "testMyViewController" to test against the newly-recorded snapshot.

Repeat test runs will load this reference and compare it with the runtime value. If they don't match, the test will fail and describe the difference. Failures can be inspected from Xcode's Report Navigator or by inspecting the file URLs of the failure.

You can record a new reference by setting the `record` parameter to `true` on the assertion or setting `isRecording` globally.

``` swift
assertSnapshot(matching: vc, as: .image, record: true)

// or globally

isRecording = true
assertSnapshot(matching: vc, as: .image)
```

## Snapshot Anything

While most snapshot testing libraries in the Swift community are limited to `UIImage`s of `UIView`s, SnapshotKit can work with _any_ format of _any_ value on _any_ Swift platform!

The `assertSnapshot` function accepts a value and any snapshot strategy that value supports. This means that a [view](Documentation/Available-Snapshot-Strategies.md#uiview) or [view controller](Documentation/Available-Snapshot-Strategies.md#uiviewcontroller) can be tested against an image representation _and_ against a textual representation of its properties and subview hierarchy.

``` swift
assertSnapshot(matching: vc, as: .image)
assertSnapshot(matching: vc, as: .recursiveDescription)
```

View testing is [highly configurable](Documentation/Available-Snapshot-Strategies.md#uiviewcontroller). You can override trait collections (for specific size classes and content size categories) and generate device-agnostic snapshots, all from a single simulator.

``` swift
assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneSe))

assertSnapshot(matching: vc, as: .image(on: .iPhoneSe(.landscape)))
assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneSe(.landscape)))

assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPhoneX))

assertSnapshot(matching: vc, as: .image(on: .iPadMini(.portrait)))
assertSnapshot(matching: vc, as: .recursiveDescription(on: .iPadMini(.portrait)))
```

> ⚠️ Warning: Snapshots may differ slightly unless compared on the same OS,
> device gamut, and scale as the simulator that originally took the reference.
> If this cannot be avoided, acceptance in differences can be configured by
> setting the `subpixelThreshold`-parameter.
>
> Example:
> ```swift
> // Allow each subpixel to deviate up to 5 byte-values
> assertSnapshot(matching: vc, as: .image(on: .iPhoneX, subpixelThreshold: 5))
> ```
>

Better yet, SnapshotKit isn't limited to views and view controllers! There are [a number of available snapshot strategies](Documentation/Available-Snapshot-Strategies.md) to choose from.

For example, you can snapshot test URL requests (_e.g._, those that your API client prepares).

``` swift
assertSnapshot(matching: urlRequest, as: .raw)
// POST http://localhost:8080/account
// Cookie: pf_session={"userId":"1"}
//
// email=blob%40pointfree.co&name=Blob
```

And you can snapshot test `Encodable` values against their JSON _and_ property list representations.

``` swift
assertSnapshot(matching: user, as: .json)
// {
//   "bio" : "Blobbed around the world.",
//   "id" : 1,
//   "name" : "Blobby"
// }

assertSnapshot(matching: user, as: .plist)
// <?xml version="1.0" encoding="UTF-8"?>
// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// <plist version="1.0">
// <dict>
//   <key>bio</key>
//   <string>Blobbed around the world.</string>
//   <key>id</key>
//   <integer>1</integer>
//   <key>name</key>
//   <string>Blobby</string>
// </dict>
// </plist>
```

In fact, _[any](Documentation/Available-Snapshot-Strategies.md#any)_ value can be snapshot-tested by default using its [mirror](https://developer.apple.com/documentation/swift/mirror)!

``` swift
assertSnapshot(matching: user, as: .dump)
// ▿ User
//   - bio: "Blobbed around the world."
//   - id: 1
//   - name: "Blobby"
```

If your data can be represented as an image, text, or data, you can write a snapshot test for it! Check out [all of the snapshot strategies](Documentation/Available-Snapshot-Strategies.md) that ship with SnapshotKit and [learn how to define your own custom strategies](Documentation/Defining-Custom-Snapshot-Strategies.md).

## Installation

### Xcode 11

> ⚠️ Warning: By default, Xcode will try to add the SnapshotKit package to your project's main application/framework target. Please ensure that SnapshotKit is added to a _test_ target instead, as documented in the last step, below.

 1. From the **File** menu, navigate through **Swift Packages** and select **Add Package Dependency…**.
 2. Enter package repository URL: `https://github.com/pointfreeco/swift-snapshot-testing.git`
 3. Confirm the version and let Xcode resolve the package
 4. On the final dialog, update SnapshotKit's **Add to Target** column to a test target that will contain snapshot tests (if you have more than one test target, you can later add SnapshotKit to them by manually linking the library in its build phase)

### Swift Package Manager

If you want to use SnapshotKit in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/lunij/SnapshotKit.git", from: "1.0.0")
]
```

Next, add `SnapshotKit` as a dependency of your test target:

```swift
targets: [
    .target(name: "MyApp"),
    .testTarget(
        name: "MyAppTests",
        dependencies: [
            "MyApp",
            .product(name: "SnapshotKit", package: "SnapshotKit")
        ]
    )
]
```

### CocoaPods

If your project uses [CocoaPods](https://cocoapods.org), add the pod to any applicable test targets in your `Podfile`:

```ruby
target 'MyAppTests' do
    pod 'SnapshotKit', '~> 1.0.0'
end
```

## Features

  - [**Dozens of snapshot strategies**](Documentation/Available-Snapshot-Strategies.md). Snapshot testing isn't just for `UIView`s and `CALayer`s. Write snapshots against _any_ value.
  - [**Write your own snapshot strategies**](Documentation/Defining-Custom-Snapshot-Strategies.md). If you can convert it to an image, string, data, or your own diffable format, you can snapshot test it! Build your own snapshot strategies from scratch or transform existing ones.
  - **No configuration required.** Don't fuss with scheme settings and environment variables. Snapshots are automatically saved alongside your tests.
  - **More hands-off.** New snapshots are recorded whether `isRecording` mode is `true` or not.
  - **Subclass-free.** Assert from any XCTest case or Quick spec.
  - **Device-agnostic snapshots.** Render views and view controllers for specific devices and trait collections from a single simulator.
  - **First-class Xcode support.** Image differences are captured as XCTest attachments. Text differences are rendered in inline error messages.
  - **Supports any platform that supports Swift.** Write snapshot tests for iOS, Linux, macOS, and tvOS.
  - **SceneKit, SpriteKit, and WebKit support.** Most snapshot testing libraries don't support these view subclasses.
  - **`Codable` support**. Snapshot encodable data structures into their [JSON](Documentation/Available-Snapshot-Strategies.md#json) and [property list](Documentation/Available-Snapshot-Strategies.md#plist) representations.
  - **Custom diff tool integration**. Configure failure messages to print diff commands for [Kaleidoscope](https://kaleidoscope.app) (or your diff tool of choice).
    ``` swift
    SnapshotKit.diffTool = "ksdiff"
    ```

## Plug-ins

  - [swift-html](https://github.com/pointfreeco/swift-html) is a Swift DSL for type-safe, extensible, and transformable HTML documents and includes an `HtmlSnapshotTesting` module to snapshot test its HTML documents.

  - [GRDBSnapshotTesting](https://github.com/SebastianOsinski/GRDBSnapshotTesting) adds snapshot strategy for testing SQLite database migrations made with [GRDB](https://github.com/groue/GRDB.swift).

  - [AccessibilitySnapshot](https://github.com/cashapp/AccessibilitySnapshot) adds easy regression testing for iOS accessibility.

  - [AccessibilitySnapshotColorBlindness](https://github.com/Sherlouk/AccessibilitySnapshotColorBlindness) adds snapshot strategies for color blindness simulation on iOS views, view controllers and images.

  - [swift-snapshot-testing-stitch](https://github.com/Sherlouk/swift-snapshot-testing-stitch/) adds the ability to stitch multiple UIView's or UIViewController's together in a single test.

## Related Tools

    - [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing/) is the framework this one is based on.

    - [`iOSSnapshotTestCase`](https://github.com/uber/ios-snapshot-test-case/) helped introduce screen shot testing to a broad audience in the iOS community.

    - [Jest](https://jestjs.io) brought generalized snapshot testing to the JavaScript community with a polished user experience. Several features of this library (diffing, automatically capturing new snapshots) were directly influenced.

<a href="https://www.pointfree.co/episodes/ep41-a-tour-of-snapshot-testing">
  <img alt="video poster image" src="https://d1hf1soyumxcgv.cloudfront.net/0041-tour-of-snapshot-testing/0041-poster.jpg" width="480">
</a>

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
