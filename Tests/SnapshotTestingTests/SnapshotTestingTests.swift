import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(SceneKit)
import SceneKit
#endif
#if canImport(SpriteKit)
import SpriteKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(WebKit)
import WebKit
#endif
#if canImport(UIKit)
import UIKit.UIView
#endif
import XCTest

@testable import SnapshotTesting

final class SnapshotTestingTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "ksdiff"
//        isRecording = true
    }

    override func tearDown() {
        isRecording = false
        super.tearDown()
    }

    func testAny() {
        struct User { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")
        assertSnapshot(matching: user, as: .dump)
        _assertInlineSnapshot(matching: user, as: .dump, with: """
        ▿ User
          - bio: "Blobbed around the world."
          - id: 1
          - name: "Blobby"
        """)
    }

    func testAnyAsJson() throws {
        struct User: Encodable { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")

        let data = try JSONEncoder().encode(user)
        let any = try JSONSerialization.jsonObject(with: data, options: [])

        assertSnapshot(matching: any, as: .json)
    }

    func testAnySnapshotStringConvertible() {
        assertSnapshot(matching: "a" as Character, as: .dump, named: "character")
        assertSnapshot(matching: Data("Hello, world!".utf8), as: .dump, named: "data")
        assertSnapshot(matching: Date(timeIntervalSinceReferenceDate: 0), as: .dump, named: "date")
        assertSnapshot(matching: NSObject(), as: .dump, named: "nsobject")
        assertSnapshot(matching: "Hello, world!", as: .dump, named: "string")
        assertSnapshot(matching: "Hello, world!".dropLast(8), as: .dump, named: "substring")
        assertSnapshot(matching: URL(string: "https://www.pointfree.co")!, as: .dump, named: "url")
        // Inline
        _assertInlineSnapshot(matching: "a" as Character, as: .dump, with: """
        - "a"
        """)
        _assertInlineSnapshot(matching: Data("Hello, world!".utf8), as: .dump, with: """
        - 13 bytes
        """)
        _assertInlineSnapshot(matching: Date(timeIntervalSinceReferenceDate: 0), as: .dump, with: """
        - 2001-01-01T00:00:00Z
        """)
        _assertInlineSnapshot(matching: NSObject(), as: .dump, with: """
        - <NSObject>
        """)
        _assertInlineSnapshot(matching: "Hello, world!", as: .dump, with: """
        - "Hello, world!"
        """)
        _assertInlineSnapshot(matching: "Hello, world!".dropLast(8), as: .dump, with: """
        - "Hello"
        """)
        _assertInlineSnapshot(matching: URL(string: "https://www.pointfree.co")!, as: .dump, with: """
        - https://www.pointfree.co
        """)
    }

    #if os(iOS)
    func testAutolayout() {
        let viewController = UIViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            subview.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            subview.rightAnchor.constraint(equalTo: viewController.view.rightAnchor)
        ])
        assertSnapshot(matching: viewController, as: .image)
    }
    #endif

    func testDeterministicDictionaryAndSetSnapshots() {
        struct Person: Hashable { let name: String }
        struct DictionarySetContainer { let dict: [String: Int], set: Set<Person> }
        let set = DictionarySetContainer(
            dict: ["c": 3, "a": 1, "b": 2],
            set: [.init(name: "Brandon"), .init(name: "Stephen")]
        )
        assertSnapshot(matching: set, as: .dump)
        _assertInlineSnapshot(matching: set, as: .dump, with: """
        ▿ DictionarySetContainer
          ▿ dict: 3 key/value pairs
            ▿ (2 elements)
              - key: "a"
              - value: 1
            ▿ (2 elements)
              - key: "b"
              - value: 2
            ▿ (2 elements)
              - key: "c"
              - value: 3
          ▿ set: 2 members
            ▿ Person
              - name: "Brandon"
            ▿ Person
              - name: "Stephen"
        """)
    }

    func testCaseIterable() {
        enum Direction: String, CaseIterable {
            case up, down, left, right
            var rotatedLeft: Direction {
                switch self {
                case .up: return .left
                case .down: return .right
                case .left: return .down
                case .right: return .up
                }
            }
        }

        assertSnapshot(
            matching: { $0.rotatedLeft },
            as: Snapshotting<Direction, String>.func(into: .description)
        )
    }

    #if os(iOS) || os(tvOS) || os(macOS)
    func testCGPath() {
        let path = CGPath.heart

        let osName: String
        #if os(iOS)
        osName = "iOS"
        #elseif os(tvOS)
        osName = "tvOS"
        #elseif os(macOS)
        osName = "macOS"
        #endif

        assertSnapshot(matching: path, as: .image, named: osName)
        assertSnapshot(matching: path, as: .elementsDescription, named: osName)
    }
    #endif

    func testData() {
        let data = Data([0xDE, 0xAD, 0xBE, 0xEF])

        assertSnapshot(matching: data, as: .data)
    }

    func testEncodable() {
        struct User: Encodable { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")

        assertSnapshot(matching: user, as: .json)
        assertSnapshot(matching: user, as: .plist)
    }

    func testMultipleSnapshots() {
        assertSnapshot(matching: [1], as: .dump)
        assertSnapshot(matching: [1, 2], as: .dump)
    }

    func testNamedAssertion() {
        struct User { let id: Int, name: String, bio: String }
        let user = User(id: 1, name: "Blobby", bio: "Blobbed around the world.")
        assertSnapshot(matching: user, as: .dump, named: "named")
    }

    #if os(macOS)
    func testNSBezierPath() {
        let path = NSBezierPath.heart

        assertSnapshot(matching: path, as: .image, named: "macOS")
        assertSnapshot(matching: path, as: .elementsDescription, named: "macOS")
    }

    func testNSView() {
        let view = NSView()
        view.frame = CGRect(origin: .zero, size: .init(width: 10, height: 10))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.green.cgColor
        view.layer?.cornerRadius = 5

        assertSnapshot(matching: view, as: .image)
        assertSnapshot(matching: view, as: .recursiveDescription)
    }
    #endif

    #if os(iOS) || os(macOS) || os(tvOS)
    func testPrecision() {
        #if os(iOS) || os(tvOS)
        let label = UILabel()
        #if os(iOS)
        label.frame = CGRect(origin: .zero, size: CGSize(width: 43.5, height: 20.5))
        #elseif os(tvOS)
        label.frame = CGRect(origin: .zero, size: CGSize(width: 98, height: 46))
        #endif
        label.backgroundColor = .white
        #elseif os(macOS)
        let label = NSTextField()
        label.frame = CGRect(origin: .zero, size: CGSize(width: 37, height: 16))
        label.backgroundColor = .white
        label.textColor = .black
        label.isBezeled = false
        label.isEditable = false
        #endif

        label.text = "Hello."
        assertSnapshot(matching: label, as: .image(precision: 0.9), named: platform)
        label.text = "Hello"
        assertSnapshot(matching: label, as: .image(precision: 0.9), named: platform)
    }
    #endif

    #if os(iOS) || os(macOS) || os(tvOS)
    func testSCNView() {
        XCTExpectFailure()
        XCTFail("Whether the test passes or fails, it crashes in addition because a host app seems to be required")
        if ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") { return }

        let scene = SCNScene()

        let sphereGeometry = SCNSphere(radius: 3)
        sphereGeometry.segmentCount = 200
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(sphereNode)

        sphereGeometry.firstMaterial?.diffuse.contents = URL(fileURLWithPath: String(#file), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/earth.png")

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 8)
        scene.rootNode.addChildNode(cameraNode)

        let omniLight = SCNLight()
        omniLight.type = .omni
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3Make(10, 10, 10)
        scene.rootNode.addChildNode(omniLightNode)

        assertSnapshot(
            matching: scene,
            as: .image(size: .init(width: 500, height: 500)),
            named: platform
        )
    }
    #endif

    #if os(iOS) || os(macOS) || os(tvOS)
    func testSKView() {
        XCTExpectFailure()
        XCTFail("Whether the test passes or fails, it crashes in addition because a host app seems to be required")
        if ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW") { return }

        let scene = SKScene(size: .init(width: 50, height: 50))
        let node = SKShapeNode(circleOfRadius: 15)
        node.fillColor = .red
        node.position = .init(x: 25, y: 25)
        scene.addChild(node)

        assertSnapshot(
            matching: scene,
            as: .image(size: .init(width: 50, height: 50)),
            named: platform
        )
    }
    #endif

    #if os(iOS)
    func testUITableViewController() {
        class TableViewController: UITableViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            }

            override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
                10
            }

            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "\(indexPath.row)"
                return cell
            }
        }
        let tableViewController = TableViewController()
        assertSnapshot(matching: tableViewController, as: .image(on: .iPhoneSe))
    }
    #endif

    #if os(iOS)
    func testAssertMultipleSnapshot() {
        class TableViewController: UITableViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            }

            override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
                10
            }

            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "\(indexPath.row)"
                return cell
            }
        }
        let tableViewController = TableViewController()
        assertSnapshots(matching: tableViewController, as: ["iPhoneSE-image": .image(on: .iPhoneSe), "iPad-image": .image(on: .iPadMini)])
        assertSnapshots(matching: tableViewController, as: [.image(on: .iPhoneX), .image(on: .iPhoneXsMax)])
    }
    #endif

    #if os(iOS) || os(tvOS)
    func testTraits() {
        let viewController = TestViewController()

        #if os(iOS)
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe), named: "iphone-se")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8), named: "iphone-8")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8Plus), named: "iphone-8-plus")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX), named: "iphone-x")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXr), named: "iphone-xr")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax), named: "iphone-xs-max")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini), named: "ipad-mini")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7), named: "ipad-9-7")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2), named: "ipad-10-2")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5), named: "ipad-pro-10-5")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11), named: "ipad-pro-11")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9), named: "ipad-pro-12-9")

        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPhoneSe), named: "iphone-se")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPhone8), named: "iphone-8")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPhone8Plus), named: "iphone-8-plus")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPhoneX), named: "iphone-x")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPhoneXr), named: "iphone-xr")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPhoneXsMax), named: "iphone-xs-max")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPadMini), named: "ipad-mini")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPad9_7), named: "ipad-9-7")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPad10_2), named: "ipad-10-2")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPadPro10_5), named: "ipad-pro-10-5")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPadPro11), named: "ipad-pro-11")
        assertSnapshot(matching: viewController, as: .recursiveDescription(on: .iPadPro12_9), named: "ipad-pro-12-9")

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe(.portrait)), named: "iphone-se")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8(.portrait)), named: "iphone-8")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8Plus(.portrait)), named: "iphone-8-plus")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX(.portrait)), named: "iphone-x")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXr(.portrait)), named: "iphone-xr")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax(.portrait)), named: "iphone-xs-max")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.landscape)), named: "ipad-mini")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.landscape)), named: "ipad-9-7")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.landscape)), named: "ipad-10-2")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.landscape)), named: "ipad-pro-10-5")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.landscape)), named: "ipad-pro-11")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.landscape)), named: "ipad-pro-12-9")

        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.landscape(splitView: .oneThird))), named: "ipad-mini-33-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.landscape(splitView: .oneHalf))), named: "ipad-mini-50-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.landscape(splitView: .twoThirds))), named: "ipad-mini-66-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.portrait(splitView: .oneThird))), named: "ipad-mini-33-split-portrait")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.portrait(splitView: .twoThirds))), named: "ipad-mini-66-split-portrait")

        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.landscape(splitView: .oneThird))), named: "ipad-9-7-33-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.landscape(splitView: .oneHalf))), named: "ipad-9-7-50-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.landscape(splitView: .twoThirds))), named: "ipad-9-7-66-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.portrait(splitView: .oneThird))), named: "ipad-9-7-33-split-portrait")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.portrait(splitView: .twoThirds))), named: "ipad-9-7-66-split-portrait")

        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.landscape(splitView: .oneThird))), named: "ipad-10-2-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.landscape(splitView: .oneHalf))), named: "ipad-10-2-50-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.landscape(splitView: .twoThirds))), named: "ipad-10-2-66-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.portrait(splitView: .oneThird))), named: "ipad-10-2-33-split-portrait")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.portrait(splitView: .twoThirds))), named: "ipad-10-2-66-split-portrait")

        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.landscape(splitView: .oneThird))), named: "ipad-pro-10inch-33-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.landscape(splitView: .oneHalf))), named: "ipad-pro-10inch-50-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.landscape(splitView: .twoThirds))), named: "ipad-pro-10inch-66-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.portrait(splitView: .oneThird))), named: "ipad-pro-10inch-33-split-portrait")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.portrait(splitView: .twoThirds))), named: "ipad-pro-10inch-66-split-portrait")

        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.landscape(splitView: .oneThird))), named: "ipad-pro-11inch-33-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.landscape(splitView: .oneHalf))), named: "ipad-pro-11inch-50-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.landscape(splitView: .twoThirds))), named: "ipad-pro-11inch-66-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.portrait(splitView: .oneThird))), named: "ipad-pro-11inch-33-split-portrait")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.portrait(splitView: .twoThirds))), named: "ipad-pro-11inch-66-split-portrait")

        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.landscape(splitView: .oneThird))), named: "ipad-pro-12inch-33-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.landscape(splitView: .oneHalf))), named: "ipad-pro-12inch-50-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.landscape(splitView: .twoThirds))), named: "ipad-pro-12inch-66-split-landscape")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.portrait(splitView: .oneThird))), named: "ipad-pro-12inch-33-split-portrait")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.portrait(splitView: .twoThirds))), named: "ipad-pro-12inch-66-split-portrait")

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe(.landscape)), named: "iphone-se-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8(.landscape)), named: "iphone-8-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8Plus(.landscape)), named: "iphone-8-plus-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX(.landscape)), named: "iphone-x-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXr(.landscape)), named: "iphone-xr-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax(.landscape)), named: "iphone-xs-max-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.portrait)), named: "ipad-mini-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.portrait)), named: "ipad-9-7-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.portrait)), named: "ipad-10-2-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.portrait)), named: "ipad-pro-10-5-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.portrait)), named: "ipad-pro-11-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.portrait)), named: "ipad-pro-12-9-alternative")

        allContentSizes.forEach { name, contentSize in
            assertSnapshot(
                matching: viewController,
                as: .image(on: .iPhoneSe, traits: .init(preferredContentSizeCategory: contentSize)),
                named: "iphone-se-\(name)"
            )
        }
        #elseif os(tvOS)
        assertSnapshot(matching: viewController, as: .image(on: .tv), named: "tv")
        assertSnapshot(matching: viewController, as: .image(on: .tv4K), named: "tv4k")
        #endif
    }
    #endif

    #if os(iOS)
    func testTraitsEmbeddedInTabNavigation() {
        let testViewController = TestViewController()
        let navController = UINavigationController(rootViewController: testViewController)
        let viewController = UITabBarController()
        viewController.setViewControllers([navController], animated: false)
        let precision: Float = 0.99

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe, precision: precision), named: "iphone-se")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8, precision: precision), named: "iphone-8")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8Plus, precision: precision), named: "iphone-8-plus")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX, precision: precision), named: "iphone-x")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXr, precision: precision), named: "iphone-xr")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax, precision: precision), named: "iphone-xs-max")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini, precision: precision), named: "ipad-mini")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7, precision: precision), named: "ipad-9-7")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2, precision: precision), named: "ipad-10-2")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5, precision: precision), named: "ipad-pro-10-5")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11, precision: precision), named: "ipad-pro-11")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9, precision: precision), named: "ipad-pro-12-9")

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe(.portrait), precision: precision), named: "iphone-se")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8(.portrait), precision: precision), named: "iphone-8")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8Plus(.portrait), precision: precision), named: "iphone-8-plus")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX(.portrait), precision: precision), named: "iphone-x")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXr(.portrait), precision: precision), named: "iphone-xr")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax(.portrait), precision: precision), named: "iphone-xs-max")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.landscape), precision: precision), named: "ipad-mini")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.landscape), precision: precision), named: "ipad-9-7")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.landscape), precision: precision), named: "ipad-10-2")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.landscape), precision: precision), named: "ipad-pro-10-5")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.landscape), precision: precision), named: "ipad-pro-11")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.landscape), precision: precision), named: "ipad-pro-12-9")

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe(.landscape), precision: precision), named: "iphone-se-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8(.landscape), precision: precision), named: "iphone-8-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8Plus(.landscape), precision: precision), named: "iphone-8-plus-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX(.landscape), precision: precision), named: "iphone-x-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXr(.landscape), precision: precision), named: "iphone-xr-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneXsMax(.landscape), precision: precision), named: "iphone-xs-max-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadMini(.portrait), precision: precision), named: "ipad-mini-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPad9_7(.portrait), precision: precision), named: "ipad-9-7-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPad10_2(.portrait), precision: precision), named: "ipad-10-2-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro10_5(.portrait), precision: precision), named: "ipad-pro-10-5-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro11(.portrait), precision: precision), named: "ipad-pro-11-alternative")
        assertSnapshot(matching: viewController, as: .image(on: .iPadPro12_9(.portrait), precision: precision), named: "ipad-pro-12-9-alternative")
    }
    #endif

    #if os(iOS)
    func testCollectionViewsWithMultipleScreenSizes() {
        final class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
            let flowLayout: UICollectionViewFlowLayout = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 20
                return layout
            }()

            lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

            override func viewDidLoad() {
                super.viewDidLoad()

                view.backgroundColor = .white
                view.addSubview(collectionView)

                collectionView.backgroundColor = .white
                collectionView.dataSource = self
                collectionView.delegate = self
                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
                collectionView.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    collectionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                    collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                    collectionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                    collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
                ])

                collectionView.reloadData()
            }

            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                collectionView.collectionViewLayout.invalidateLayout()
            }

            override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
                super.traitCollectionDidChange(previousTraitCollection)
                collectionView.collectionViewLayout.invalidateLayout()
            }

            func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentView.backgroundColor = .orange
                return cell
            }

            func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
                20
            }

            func collectionView(
                _ collectionView: UICollectionView,
                layout _: UICollectionViewLayout,
                sizeForItemAt _: IndexPath
            ) -> CGSize {
                CGSize(
                    width: min(collectionView.frame.width - 50, 300),
                    height: collectionView.frame.height
                )
            }
        }

        let viewController = CollectionViewController()

        assertSnapshots(matching: viewController, as: [
            "ipad": .image(on: .iPadPro12_9),
            "iphoneSe": .image(on: .iPhoneSe),
            "iphone8": .image(on: .iPhone8),
            "iphoneMax": .image(on: .iPhoneXsMax)
        ])
    }
    #endif

    #if os(iOS)
    func testTraitsWithView() {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.text = "UILabel"

        allContentSizes.forEach { name, contentSize in
            assertSnapshot(
                matching: label,
                as: .image(precision: 0.97, traits: .init(preferredContentSizeCategory: contentSize)),
                named: "label-\(name)"
            )
        }
    }

    func testTraitsWithViewController() {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.text = "UILabel"

        let viewController = UIViewController()
        viewController.view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.leadingAnchor),
            label.topAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.trailingAnchor)
        ])

        allContentSizes.forEach { name, contentSize in
            assertSnapshot(
                matching: viewController,
                as: .recursiveDescription(on: .iPhoneSe, traits: .init(preferredContentSizeCategory: contentSize)),
                named: "label-\(name)"
            )
        }
    }
    #endif

    #if os(iOS) || os(tvOS)
    func testUIBezierPath() {
        let path = UIBezierPath.heart

        let osName: String
        #if os(iOS)
        osName = "iOS"
        #elseif os(tvOS)
        osName = "tvOS"
        #endif

        assertSnapshot(matching: path, as: .image, named: osName)
        assertSnapshot(matching: path, as: .elementsDescription, named: osName)
    }
    #endif

    #if os(iOS)
    func testUIView() {
        let view = UIView()
        view.frame = .init(origin: .zero, size: .init(width: 20, height: 20))
        view.backgroundColor = .cyan
        view.layer.cornerRadius = 10

        assertSnapshot(matching: view, as: .image)
        assertSnapshot(matching: view, as: .recursiveDescription)
    }

    func testUIViewControllerLifeCycle() {
        class ViewController: UIViewController {
            let viewDidLoadExpectation: XCTestExpectation
            let viewWillAppearExpectation: XCTestExpectation
            let viewDidAppearExpectation: XCTestExpectation
            let viewWillDisappearExpectation: XCTestExpectation
            let viewDidDisappearExpectation: XCTestExpectation
            init(
                viewDidLoadExpectation: XCTestExpectation,
                viewWillAppearExpectation: XCTestExpectation,
                viewDidAppearExpectation: XCTestExpectation,
                viewWillDisappearExpectation: XCTestExpectation,
                viewDidDisappearExpectation: XCTestExpectation
            ) {
                self.viewDidLoadExpectation = viewDidLoadExpectation
                self.viewWillAppearExpectation = viewWillAppearExpectation
                self.viewDidAppearExpectation = viewDidAppearExpectation
                self.viewWillDisappearExpectation = viewWillDisappearExpectation
                self.viewDidDisappearExpectation = viewDidDisappearExpectation
                super.init(nibName: nil, bundle: nil)
            }

            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            override func viewDidLoad() {
                super.viewDidLoad()
                viewDidLoadExpectation.fulfill()
            }

            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                viewWillAppearExpectation.fulfill()
            }

            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                viewDidAppearExpectation.fulfill()
            }

            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                viewWillDisappearExpectation.fulfill()
            }

            override func viewDidDisappear(_ animated: Bool) {
                super.viewDidDisappear(animated)
                viewDidDisappearExpectation.fulfill()
            }
        }

        let viewDidLoadExpectation = expectation(description: "viewDidLoad")
        let viewWillAppearExpectation = expectation(description: "viewWillAppear")
        let viewDidAppearExpectation = expectation(description: "viewDidAppear")
        let viewWillDisappearExpectation = expectation(description: "viewWillDisappear")
        let viewDidDisappearExpectation = expectation(description: "viewDidDisappear")
        viewWillAppearExpectation.expectedFulfillmentCount = 2
        viewDidAppearExpectation.expectedFulfillmentCount = 2
        viewWillDisappearExpectation.expectedFulfillmentCount = 2
        viewDidDisappearExpectation.expectedFulfillmentCount = 2

        let viewController = ViewController(
            viewDidLoadExpectation: viewDidLoadExpectation,
            viewWillAppearExpectation: viewWillAppearExpectation,
            viewDidAppearExpectation: viewDidAppearExpectation,
            viewWillDisappearExpectation: viewWillDisappearExpectation,
            viewDidDisappearExpectation: viewDidDisappearExpectation
        )

        assertSnapshot(matching: viewController, as: .image)
        assertSnapshot(matching: viewController, as: .image)

        wait(
            for: [
                viewDidLoadExpectation,
                viewWillAppearExpectation,
                viewDidAppearExpectation,
                viewWillDisappearExpectation,
                viewDidDisappearExpectation
            ],
            timeout: 1,
            enforceOrder: true
        )
    }

    func testCALayer() {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        layer.backgroundColor = UIColor.red.cgColor
        layer.borderWidth = 4.0
        layer.borderColor = UIColor.black.cgColor
        assertSnapshot(matching: layer, as: .image)
    }

    func testCALayerWithGradient() {
        let baseLayer = CALayer()
        baseLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        gradientLayer.frame = baseLayer.frame
        baseLayer.addSublayer(gradientLayer)
        assertSnapshot(matching: baseLayer, as: .image)
    }

    func testViewControllerHierarchy() {
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        page.setViewControllers([UIViewController()], direction: .forward, animated: false)
        let tab = UITabBarController()
        tab.viewControllers = [
            UINavigationController(rootViewController: page),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: UIViewController())
        ]
        assertSnapshot(matching: tab, as: .hierarchy)
    }
    #endif

    func testURLRequest() {
        var get = URLRequest(url: URL(string: "https://www.pointfree.co/")!)
        get.addValue("pf_session={}", forHTTPHeaderField: "Cookie")
        get.addValue("text/html", forHTTPHeaderField: "Accept")
        get.addValue("application/json", forHTTPHeaderField: "Content-Type")
        assertSnapshot(matching: get, as: .raw, named: "get")
        assertSnapshot(matching: get, as: .curl, named: "get-curl")

        var getWithQuery = URLRequest(url: URL(string: "https://www.pointfree.co?key_2=value_2&key_1=value_1&key_3=value_3")!)
        getWithQuery.addValue("pf_session={}", forHTTPHeaderField: "Cookie")
        getWithQuery.addValue("text/html", forHTTPHeaderField: "Accept")
        getWithQuery.addValue("application/json", forHTTPHeaderField: "Content-Type")
        assertSnapshot(matching: getWithQuery, as: .raw, named: "get-with-query")
        assertSnapshot(matching: getWithQuery, as: .curl, named: "get-with-query-curl")

        var post = URLRequest(url: URL(string: "https://www.pointfree.co/subscribe")!)
        post.httpMethod = "POST"
        post.addValue("pf_session={\"user_id\":\"0\"}", forHTTPHeaderField: "Cookie")
        post.addValue("text/html", forHTTPHeaderField: "Accept")
        post.httpBody = Data("pricing[billing]=monthly&pricing[lane]=individual".utf8)
        assertSnapshot(matching: post, as: .raw, named: "post")
        assertSnapshot(matching: post, as: .curl, named: "post-curl")

        var postWithJSON = URLRequest(url: URL(string: "http://dummy.restapiexample.com/api/v1/create")!)
        postWithJSON.httpMethod = "POST"
        postWithJSON.addValue("application/json", forHTTPHeaderField: "Content-Type")
        postWithJSON.addValue("application/json", forHTTPHeaderField: "Accept")
        postWithJSON.httpBody = Data("{\"name\":\"tammy134235345235\", \"salary\":0, \"age\":\"tammy133\"}".utf8)
        assertSnapshot(matching: postWithJSON, as: .raw, named: "post-with-json")
        assertSnapshot(matching: postWithJSON, as: .curl, named: "post-with-json-curl")

        var head = URLRequest(url: URL(string: "https://www.pointfree.co/")!)
        head.httpMethod = "HEAD"
        head.addValue("pf_session={}", forHTTPHeaderField: "Cookie")
        assertSnapshot(matching: head, as: .raw, named: "head")
        assertSnapshot(matching: head, as: .curl, named: "head-curl")

        post = URLRequest(url: URL(string: "https://www.pointfree.co/subscribe")!)
        post.httpMethod = "POST"
        post.addValue("pf_session={\"user_id\":\"0\"}", forHTTPHeaderField: "Cookie")
        post.addValue("application/json", forHTTPHeaderField: "Accept")
        post.httpBody = Data("""
        {"pricing": {"lane": "individual","billing": "monthly"}}
        """.utf8)
        _assertInlineSnapshot(matching: post, as: .raw(pretty: true), with: """
        POST https://www.pointfree.co/subscribe
        Accept: application/json
        Cookie: pf_session={"user_id":"0"}

        {
          "pricing" : {
            "billing" : "monthly",
            "lane" : "individual"
          }
        }
        """)
    }

    #if os(iOS) || os(macOS)
    func testWebView() throws {
        let fixtureUrl = URL(fileURLWithPath: String(#file), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
            matching: webView,
            as: .image(precision: 0.9, size: .init(width: 800, height: 600)),
            named: platform
        )
    }
    #endif

    #if os(iOS) || os(tvOS)
    func testViewWithZeroHeightOrWidth() {
        var rect = CGRect(x: 0, y: 0, width: 350, height: 0)
        var view = UIView(frame: rect)
        view.backgroundColor = .red
        assertSnapshot(matching: view, as: .image, named: "noHeight")

        rect = CGRect(x: 0, y: 0, width: 0, height: 350)
        view = UIView(frame: rect)
        view.backgroundColor = .green
        assertSnapshot(matching: view, as: .image, named: "noWidth")

        rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        view = UIView(frame: rect)
        view.backgroundColor = .blue
        assertSnapshot(matching: view, as: .image, named: "noWidth.noHeight")
    }
    #endif

    #if os(iOS)
    func testEmbeddedWebView() throws {
        let label = UILabel()
        label.text = "Hello, Blob!"

        let fixtureUrl = URL(fileURLWithPath: String(#file), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        webView.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [label, webView])
        stackView.axis = .vertical

        assertSnapshot(
            matching: stackView,
            as: .image(size: .init(width: 800, height: 600)),
            named: platform
        )
    }
    #endif

    #if os(iOS) || os(macOS)
    final class ManipulatingWKWebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            webView.evaluateJavaScript("document.body.children[0].classList.remove(\"hero\")") // Change layout
        }
    }

    func testWebViewWithManipulatingNavigationDelegate() throws {
        let manipulatingWKWebViewNavigationDelegate = ManipulatingWKWebViewNavigationDelegate()
        let webView = WKWebView()
        webView.navigationDelegate = manipulatingWKWebViewNavigationDelegate

        let fixtureUrl = URL(fileURLWithPath: String(#file), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
            matching: webView,
            as: .image(precision: 0.9, size: .init(width: 800, height: 600)),
            named: platform
        )

        _ = manipulatingWKWebViewNavigationDelegate
    }

    final class CancellingWKWebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(
            _: WKWebView,
            decidePolicyFor _: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            decisionHandler(.cancel)
        }
    }

    func testWebViewWithCancellingNavigationDelegate() throws {
        let cancellingWKWebViewNavigationDelegate = CancellingWKWebViewNavigationDelegate()
        let webView = WKWebView()
        webView.navigationDelegate = cancellingWKWebViewNavigationDelegate

        let fixtureUrl = URL(fileURLWithPath: String(#file), isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("__Fixtures__/pointfree.html")
        let html = try String(contentsOf: fixtureUrl)
        webView.loadHTMLString(html, baseURL: nil)

        assertSnapshot(
            matching: webView,
            as: .image(size: .init(width: 800, height: 600)),
            named: platform
        )

        _ = cancellingWKWebViewNavigationDelegate
    }
    #endif

    #if os(iOS)
    @available(iOS 13.0, *)
    func testSwiftUIView_iOS() {
        let view = TestView().environment(\.colorScheme, .light)
        let precision: Float = 0.99

        assertSnapshot(matching: view, as: .image(precision: precision, traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(matching: view, as: .image(precision: precision, layout: .sizeThatFits, traits: .init(userInterfaceStyle: .light)), named: "size-that-fits")
        assertSnapshot(matching: view, as: .image(precision: precision, layout: .fixed(width: 200, height: 100), traits: .init(userInterfaceStyle: .light)), named: "fixed")
        assertSnapshot(matching: view, as: .image(precision: precision, layout: .device(config: .iPhoneSe), traits: .init(userInterfaceStyle: .light)), named: "device")
    }
    #endif

    #if os(macOS)
    @available(macOS 11.0, *)
    func testSwiftUIView_macOS() {
        let view = TestView().environment(\.colorScheme, .light)

        assertSnapshot(matching: view, as: .image(size: .init(width: 100, height: 50), precision: 0.98))
    }
    #endif

    #if os(tvOS)
    @available(tvOS 13.0, *)
    func testSwiftUIView_tvOS() {
        let view = TestView().environment(\.colorScheme, .light)

        assertSnapshot(matching: view, as: .image())
        assertSnapshot(matching: view, as: .image(layout: .sizeThatFits), named: "size-that-fits")
        assertSnapshot(matching: view, as: .image(layout: .fixed(width: 300, height: 100)), named: "fixed")
        assertSnapshot(matching: view, as: .image(layout: .device(config: .tv)), named: "device")
    }
    #endif
}

#if os(iOS) || os(tvOS)
class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let topView = UIView()
        let leadingView = UIView()
        let trailingView = UIView()
        let bottomView = UIView()

        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .add, target: nil, action: nil)

        view.backgroundColor = .white

        topView.backgroundColor = .blue
        leadingView.backgroundColor = .green
        trailingView.backgroundColor = .red
        bottomView.backgroundColor = .magenta

        topView.translatesAutoresizingMaskIntoConstraints = false
        leadingView.translatesAutoresizingMaskIntoConstraints = false
        trailingView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topView)
        view.addSubview(leadingView)
        view.addSubview(trailingView)
        view.addSubview(bottomView)

        let constant: CGFloat = 50

        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            topView.widthAnchor.constraint(equalToConstant: constant),
            topView.heightAnchor.constraint(equalToConstant: constant),
            leadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            leadingView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            leadingView.widthAnchor.constraint(equalToConstant: constant),
            leadingView.heightAnchor.constraint(equalToConstant: constant),
            trailingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trailingView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            trailingView.widthAnchor.constraint(equalToConstant: constant),
            trailingView.heightAnchor.constraint(equalToConstant: constant),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            bottomView.widthAnchor.constraint(equalToConstant: constant),
            bottomView.heightAnchor.constraint(equalToConstant: constant)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }
}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
private struct TestView: SwiftUI.View {
    var body: some SwiftUI.View {
        HStack {
            SwiftUI.Image(systemName: "checkmark.circle.fill")
            Text("Checked").fixedSize()
        }
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 5).fill(Color.blue))
        .padding(10)
        .background(Color.yellow)
    }
}
#endif

#if os(iOS)
private let allContentSizes =
    [
        "extra-small": UIContentSizeCategory.extraSmall,
        "small": .small,
        "medium": .medium,
        "large": .large,
        "extra-large": .extraLarge,
        "extra-extra-large": .extraExtraLarge,
        "extra-extra-extra-large": .extraExtraExtraLarge,
        "accessibility-medium": .accessibilityMedium,
        "accessibility-large": .accessibilityLarge,
        "accessibility-extra-large": .accessibilityExtraLarge,
        "accessibility-extra-extra-large": .accessibilityExtraExtraLarge,
        "accessibility-extra-extra-extra-large": .accessibilityExtraExtraExtraLarge
    ]
#endif
