// swift-tools-version: 5.9
// This file is auto-generated. Do not edit this file directly. Instead, make changes in `Package/` directory and then run `package.sh` to generate a new `Package.swift` file.
//
// Array+Depedencies.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension [Dependency]: Dependencies {
    func appending(_ dependencies: any Dependencies) -> [Dependency] {
        self + dependencies
    }
}
//
// Array+SupportedPlatforms.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension [SupportedPlatform]: SupportedPlatforms {
    func appending(_ platforms: any SupportedPlatforms) -> Self {
        self + .init(platforms)
    }
}
//
// Array+TestTargets.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension [TestTarget]: TestTargets {
    func appending(_ testTargets: any TestTargets) -> [TestTarget] {
        self + testTargets
    }
}
//
//  CSettingsBuilder.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

@resultBuilder
enum CSettingsBuilder {
    static func buildPartialBlock(first: CSetting) -> [CSetting] {
        [first]
    }

    static func buildPartialBlock(accumulated: [CSetting], next: CSetting) -> [CSetting] {
        accumulated + [next]
    }
}
//
// Dependencies.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol Dependencies: Sequence where Element == Dependency {
    // swiftlint:disable:next identifier_name
    init<S>(_ s: S) where S.Element == Dependency, S: Sequence
    func appending(_ dependencies: any Dependencies) -> Self
}
//
// Dependency.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol Dependency {
    var targetDepenency: _PackageDescription_TargetDependency { get }
}
//
// DependencyBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum DependencyBuilder {
    static func buildPartialBlock(first: Dependency) -> any Dependencies {
        [first]
    }

    static func buildPartialBlock(accumulated: any Dependencies, next: Dependency) -> any Dependencies {
        accumulated + [next]
    }
}
//
// LanguageTag.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension LanguageTag {
    static let english: LanguageTag = "en"
}
//
//  Macro.swift
//
//
//  Created by ErrorErrorError on 10/11/23.
//
//

import CompilerPluginSupport
import Foundation

// MARK: - Macro

protocol Macro: Target {}

extension Macro {
    var targetType: TargetType {
        .macro
    }

    var targetDepenency: _PackageDescription_TargetDependency {
        .target(name: name)
    }

    var cSettings: [CSetting] {
        []
    }

    var swiftSettings: [SwiftSetting] {
        []
    }

    var resources: [Resource] {
        []
    }
}
//
// Package+Extensions.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Package {
    convenience init(
        name: String? = nil,
        @ProductsBuilder entries: @escaping () -> [Product],
        @TestTargetBuilder testTargets: @escaping () -> any TestTargets = { [TestTarget]() },
        @SwiftSettingsBuilder swiftSettings: @escaping () -> [SwiftSetting] = { [SwiftSetting]() }
    ) {
        let packageName: String
        if let name {
            packageName = name
        } else {
            var pathComponents = #filePath.split(separator: "/")
            pathComponents.removeLast()
            // swiftlint:disable:next force_unwrapping
            packageName = String(pathComponents.last!)
        }
        let allTestTargets = testTargets()
        let entries = entries()
        let products = entries.map(_PackageDescription_Product.entry)
        var targets = entries.flatMap(\.productTargets)
        let allTargetsDependencies = targets.flatMap { $0.allDependencies() }
        let allTestTargetsDependencies = allTestTargets.flatMap { $0.allDependencies() }
        let dependencies = allTargetsDependencies + allTestTargetsDependencies
        let targetDependencies = dependencies.compactMap { $0 as? Target }
        let packageDependencies = dependencies.compactMap { $0 as? PackageDependency }
        targets += targetDependencies
        targets += allTestTargets.map { $0 as Target }
//    assert(targetDependencies.count + packageDependencies.count == dependencies.count, "there was a miscount of target dependencies - target: \(targetDependencies.count), package:
//    \(packageDependencies.count), expected: \(dependencies.count)")

        let packgeTargets = Dictionary(
            grouping: targets,
            by: { $0.name }
        )
        .values
        .compactMap(\.first)
        .map { _PackageDescription_Target.entry($0, swiftSettings: swiftSettings()) }

        let packageDeps = Dictionary(
            grouping: packageDependencies,
            by: { $0.productName }
        ).values.compactMap(\.first).map(\.dependency)

        self.init(name: packageName, products: products, dependencies: packageDeps, targets: packgeTargets)
    }
}

extension Package {
    func supportedPlatforms(
        @SupportedPlatformBuilder supportedPlatforms: @escaping () -> any SupportedPlatforms
    ) -> Package {
        platforms = .init(supportedPlatforms())
        return self
    }

    func defaultLocalization(_ defaultLocalization: LanguageTag) -> Package {
        self.defaultLocalization = defaultLocalization
        return self
    }
}
//
// PackageDependency.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

import PackageDescription

// MARK: - PackageDependency

protocol PackageDependency: Dependency {
    init()

    var packageName: String { get }
    var dependency: _PackageDescription_PackageDependency { get }
}

extension PackageDependency {
    var productName: String {
        "\(Self.self)"
    }

    var packageName: String {
        switch dependency.kind {
        case let .sourceControl(name: name, location: location, requirement: _):
            return name ?? location.packageName ?? productName
        case let .fileSystem(name: name, path: path):
            return name ?? path.packageName ?? productName
        case let .registry(id: id, requirement: _):
            return id
        @unknown default:
            return productName
        }
    }

    var targetDepenency: _PackageDescription_TargetDependency {
        switch dependency.kind {
        case let .sourceControl(name: name, location: location, requirement: _):
            let packageName = name ?? location.packageName
            return .product(name: productName, package: packageName)

        default:
            return .byName(name: productName)
        }
    }
}
//
// PackageDescription.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// swiftlint:disable type_name

import PackageDescription

typealias _PackageDescription_Product = PackageDescription.Product
typealias _PackageDescription_Target = PackageDescription.Target
typealias _PackageDescription_TargetDependency = PackageDescription.Target.Dependency
typealias _PackageDescription_PackageDependency = PackageDescription.Package.Dependency
//
// PlatformSet.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol PlatformSet {
    @SupportedPlatformBuilder
    var body: any SupportedPlatforms { get }
}
//
// Product+Target.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension Product where Self: Target {
    var productTargets: [Target] {
        [self]
    }

    var targetType: TargetType {
        switch productType {
        case .library:
            .regular

        case .executable:
            .executable
        }
    }
}
//
// Product.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// MARK: - Product

protocol Product: _Named {
    var productTargets: [Target] { get }
    var productType: ProductType { get }
}

extension Product {
    var productType: ProductType {
        .library
    }
}
//
// ProductType.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

enum ProductType {
    case library
    case executable
}
//
// ProductsBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum ProductsBuilder {
    static func buildPartialBlock(first: Product) -> [Product] {
        [first]
    }

    static func buildPartialBlock(accumulated: [Product], next: Product) -> [Product] {
        accumulated + [next]
    }
}
//
// ResourcesBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum ResourcesBuilder {
    static func buildPartialBlock(first: Resource) -> [Resource] {
        [first]
    }

    static func buildPartialBlock(accumulated: [Resource], next: Resource) -> [Resource] {
        accumulated + [next]
    }
}
//
// String.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension String {
    var packageName: String? {
        split(separator: "/").last?.split(separator: ".").first.map(String.init)
    }
}
//
// SupportedPlatformBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

import PackageDescription

@resultBuilder
enum SupportedPlatformBuilder {
    static func buildPartialBlock(first: SupportedPlatform) -> any SupportedPlatforms {
        [first]
    }

    static func buildPartialBlock(first: PlatformSet) -> any SupportedPlatforms {
        first.body
    }

    static func buildPartialBlock(first: any SupportedPlatforms) -> any SupportedPlatforms {
        first
    }

    static func buildPartialBlock(
        accumulated: any SupportedPlatforms,
        next: any SupportedPlatforms
    ) -> any SupportedPlatforms {
        accumulated.appending(next)
    }

    static func buildPartialBlock(
        accumulated: any SupportedPlatforms,
        next: SupportedPlatform
    ) -> any SupportedPlatforms {
        accumulated.appending([next])
    }
}
//
// SupportedPlatforms.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol SupportedPlatforms: Sequence where Element == SupportedPlatform {
    // swiftlint:disable:next identifier_name
    init<S>(_ s: S) where S.Element == SupportedPlatform, S: Sequence
    func appending(_ platforms: any SupportedPlatforms) -> Self
}
//
// SwiftSettingsBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum SwiftSettingsBuilder {
    static func buildPartialBlock(first: SwiftSetting) -> [SwiftSetting] {
        [first]
    }

    static func buildPartialBlock(accumulated: [SwiftSetting], next: SwiftSetting) -> [SwiftSetting] {
        accumulated + [next]
    }
}
//
// Target.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// MARK: - Target

protocol Target: _Depending, Dependency, _Named, _Path {
    var targetType: TargetType { get }

    @CSettingsBuilder
    var cSettings: [CSetting] { get }

    @SwiftSettingsBuilder
    var swiftSettings: [SwiftSetting] { get }

    @ResourcesBuilder
    var resources: [Resource] { get }
}

extension Target {
    var targetType: TargetType {
        .regular
    }

    var targetDepenency: _PackageDescription_TargetDependency {
        .target(name: name)
    }

    var cSettings: [CSetting] {
        []
    }

    var swiftSettings: [SwiftSetting] {
        []
    }

    var resources: [Resource] {
        []
    }
}
//
// TargetType.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// typealias TargetType = Target.TargetType

enum TargetType {
    case regular
    case executable
    case test
    case binary(BinaryTarget)
    case macro

    enum BinaryTarget {
        case path(String)
        case remote(url: String, checksum: String)
    }
}
//
// TestTarget.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// MARK: - TestTarget

protocol TestTarget: Target {}

extension TestTarget {
    var targetType: TargetType {
        .test
    }
}
//
// TestTargetBuilder.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

@resultBuilder
enum TestTargetBuilder {
    static func buildPartialBlock(first: TestTarget) -> any TestTargets {
        [first]
    }

    static func buildPartialBlock(accumulated: any TestTargets, next: TestTarget) -> any TestTargets {
        accumulated + [next]
    }
}
//
// TestTargets.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

protocol TestTargets: Sequence where Element == TestTarget {
    // swiftlint:disable:next identifier_name
    init<S>(_ s: S) where S.Element == TestTarget, S: Sequence
    func appending(_ testTargets: any TestTargets) -> Self
}
//
//  Testable.swift
//
//
//  Created by ErrorErrorError on 10/13/23.
//
//

import Foundation

protocol Testable {
    associatedtype Tests: TestTarget
}
//
// _Depending.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// MARK: - _Depending

protocol _Depending {
    @DependencyBuilder
    var dependencies: any Dependencies { get }
}

extension _Depending {
    var dependencies: any Dependencies {
        [Dependency]()
    }
}

extension _Depending {
    func allDependencies() -> [Dependency] {
        dependencies.compactMap {
            $0 as? _Depending
        }
        .flatMap {
            $0.allDependencies()
        }
        .appending(dependencies)
    }
}
//
// _Named.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

// MARK: - _Named

protocol _Named {
    var name: String { get }
}

extension _Named {
    var name: String {
        "\(Self.self)"
    }
}
//
// _PackageDescription_Product.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension _PackageDescription_Product {
    static func entry(_ entry: Product) -> _PackageDescription_Product {
        let targets = entry.productTargets.map(\.name)

        switch entry.productType {
        case .executable:
            return Self.executable(name: entry.name, targets: targets)

        case .library:
            return Self.library(name: entry.name, targets: targets)
        }
    }
}
//
// _PackageDescription_Target.swift
// Copyright (c) 2023 BrightDigit.
// Licensed under MIT License
//

extension _PackageDescription_Target {
    static func entry(_ entry: Target, swiftSettings: [SwiftSetting] = []) -> _PackageDescription_Target {
        let dependencies = entry.dependencies.map(\.targetDepenency)
        switch entry.targetType {
        case .executable:
            return .executableTarget(
                name: entry.name,
                dependencies: dependencies,
                path: entry.path,
                resources: entry.resources,
                cSettings: entry.cSettings,
                swiftSettings: swiftSettings + entry.swiftSettings
            )

        case .regular:
            return .target(
                name: entry.name,
                dependencies: dependencies,
                path: entry.path,
                resources: entry.resources,
                cSettings: entry.cSettings,
                swiftSettings: swiftSettings + entry.swiftSettings
            )

        case .test:
            return .testTarget(
                name: entry.name,
                dependencies: dependencies,
                path: entry.path,
                resources: entry.resources,
                cSettings: entry.cSettings,
                swiftSettings: swiftSettings + entry.swiftSettings
            )

        case let .binary(.path(path)):
            return .binaryTarget(
                name: entry.name,
                path: path
            )

        case let .binary(.remote(url, checksum)):
            return .binaryTarget(
                name: entry.name,
                url: url,
                checksum: checksum
            )

        case .macro:
            return .macro(
                name: entry.name,
                dependencies: dependencies,
                path: entry.path,
                swiftSettings: swiftSettings + entry.swiftSettings
            )
        }
    }
}
//
//  _Path.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

// MARK: - _Path

protocol _Path {
    var path: String? { get }
}

extension _Path {
    var path: String? { nil }
}
//
//  AnalyticsClient.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

import Foundation

struct AnalyticsClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  BuildClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct BuildClient: _Client {
    var dependencies: any Dependencies {
        Semver()
        ComposableArchitecture()
    }
}
//
//  ClipboardClient.swift
//
//
//  Created by ErrorErrorError on 12/15/23.
//
//

import Foundation

struct ClipboardClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  DatabaseClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct DatabaseClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
        Semver()
        Tagged()
        CoreDB()
    }

    var resources: [Resource] {
        Resource.copy("Resources/MochiSchema.xcdatamodeld")
    }
}
//
//  DeviceClient.swift
//
//
//  Created by ErrorErrorError on 11/29/23.
//
//

struct DeviceClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  FileClient.swift
//
//
//  Created by ErrorErrorError on 10/6/23.
//
//

struct FileClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  LocalizableClient.swift
//
//
//  Created by ErrorErrorError on 12/1/23.
//
//

import Foundation

struct LocalizableClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }

    var resources: [Resource] {
        Resource.process("Resources")
    }
}
//
//  LoggerClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct LoggerClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
        Logging()
    }
}
//
//  ModuleClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

// MARK: - ModuleClient

struct ModuleClient: _Client {
    var dependencies: any Dependencies {
        DatabaseClient()
        FileClient()
        SharedModels()
        Tagged()
        ComposableArchitecture()
        SwiftSoup()
        Semaphore()
        JSValueCoder()
        LoggerClient()
        Parsing()
    }
}

// MARK: Testable

extension ModuleClient: Testable {
    struct Tests: TestTarget {
        var name: String { "ModuleClientTests" }

        var dependencies: any Dependencies {
            ModuleClient()
        }

        var resources: [Resource] {
            Resource.copy("Resources")
        }
    }
}
//
//  PlayerClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct PlayerClient: _Client {
    var dependencies: any Dependencies {
        Architecture()
        ModuleClient()
        SharedModels()
        Styling()
        UserDefaultsClient()
        ComposableArchitecture()
        ViewComponents()
        XMLCoder()
    }
}
//
//  PlaylistHistoryClient.swift
//
//
//  Created by DeNeRr on 29.01.2024.
//

import Foundation

struct PlaylistHistoryClient: _Client {
    var dependencies: any Dependencies {
        DatabaseClient()
        SharedModels()
        Semaphore()
        Tagged()
        ComposableArchitecture()
    }
}
//
//  RepoClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct RepoClient: _Client {
    var dependencies: any Dependencies {
        DatabaseClient()
        FileClient()
        Semaphore()
        SharedModels()
        Tagged()
        ComposableArchitecture()
    }
}
//
//  UserDefaultsClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct UserDefaultsClient: _Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
    }
}
//
//  UserSettingsClient.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct UserSettingsClient: _Client {
    var dependencies: any Dependencies {
        UserDefaultsClient()
        ComposableArchitecture()
        ViewComponents()
    }
}
//
//  _Client.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

// MARK: - _Client

protocol _Client: Product, Target {}

extension _Client {
    var path: String? {
        "Sources/Clients/\(name)"
    }
}
//
//  ComposableArchitecture.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

struct ComposableArchitecture: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.5.6")
    }
}
//
//  CustomDump.swift
//
//
//  Created by ErrorErrorError on 1/1/24.
//
//

import Foundation

struct CustomDump: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0")
    }
}
//
//  FluidGradient.swift
//
//
//  Created by ErrorErrorError on 10/11/23.
//
//

import Foundation

struct FluidGradient: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/Cindori/FluidGradient.git", exact: "1.0.0")
    }
}
//
//  Nuke.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

// MARK: - Nuke

struct Nuke: PackageDependency {
    static let nukeURL = "https://github.com/kean/Nuke.git"
    static let nukeVersion: Version = "12.1.6"

    var dependency: Package.Dependency {
        .package(url: Self.nukeURL, exact: Self.nukeVersion)
    }
}

// MARK: - NukeUI

struct NukeUI: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: Nuke.nukeURL, exact: Nuke.nukeVersion)
    }
}
//
//  Parsing.swift
//
//
//  Created by ErrorErrorError on 12/17/23.
//
//

struct Parsing: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-parsing", exact: "0.13.0")
    }
}
//
//  Semaphore.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

struct Semaphore: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/groue/Semaphore", exact: "0.0.8")
    }
}
//
//  Semver.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

struct Semver: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/semver/Semver.git", exact: "1.0.0")
    }
}
//
//  SwiftLog.swift
//
//
//  Created by ErrorErrorError on 11/9/23.
//
//

// MARK: - SwiftLog

struct SwiftLog: PackageDependency {
    var name: String { "swift-log" }
    var productName: String { "swift-log" }

    var dependency: Package.Dependency {
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    }
}

// MARK: - Logging

struct Logging: _Depending, Dependency {
    var targetDepenency: _PackageDescription_TargetDependency {
        .product(name: "\(Self.self)", package: SwiftLog().packageName)
    }

    var dependencies: any Dependencies {
        SwiftLog()
    }
}
//
//  SwiftSoup.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

struct SwiftSoup: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
    }
}
//
//  SwiftSyntax.swift
//
//
//  Created by ErrorErrorError on 10/11/23.
//
//

import Foundation

// MARK: - SwiftSyntax

struct SwiftSyntax: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.1")
    }
}

// MARK: - SwiftSyntaxMacros

struct SwiftSyntaxMacros: _Depending, Dependency {
    var targetDepenency: _PackageDescription_TargetDependency {
        .product(name: "\(Self.self)", package: SwiftSyntax().packageName)
    }

    var dependencies: any Dependencies {
        SwiftSyntax()
    }
}

// MARK: - SwiftCompilerPlugin

struct SwiftCompilerPlugin: _Depending, Dependency {
    var targetDepenency: _PackageDescription_TargetDependency {
        .product(name: "\(Self.self)", package: SwiftSyntax().packageName)
    }

    var dependencies: any Dependencies {
        SwiftSyntax()
    }
}
//
//  SwiftUIBackports.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

struct SwiftUIBackports: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/shaps80/SwiftUIBackports.git", .upToNextMajor(from: "2.0.0"))
    }
}
//
//  Tagged.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct Tagged: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-tagged", exact: "0.10.0")
    }
}
//
//  XMLCoder.swift
//
//
//  Created by ErrorErrorError on 12/27/23.
//
//

struct XMLCoder: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", exact: "0.17.1")
    }
}
//
//  ContentCore.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct ContentCore: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        FoundationHelpers()
        ModuleClient()
        LoggerClient()
        Tagged()
        ComposableArchitecture()
        Styling()
    }
}
//
//  Discover.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct Discover: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        PlaylistDetails()
        ModuleClient()
        ModuleLists()
        RepoClient()
        Search()
        Styling()
        SharedModels()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  MochiApp.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

import Foundation

struct MochiApp: _Feature {
    var name: String { "App" }

    var dependencies: any Dependencies {
        Architecture()
        Discover()
        Repos()
        Settings()
        SharedModels()
        Styling()
        UserSettingsClient()
        VideoPlayer()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  ModuleLists.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct ModuleLists: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        RepoClient()
        Styling()
        SharedModels()
        ViewComponents()
        ComposableArchitecture()
    }
}
//
//  PlaylistDetails.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct PlaylistDetails: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        ContentCore()
        LoggerClient()
        ModuleClient()
        RepoClient()
        PlaylistHistoryClient()
        Styling()
        SharedModels()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  Repos.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct Repos: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        ClipboardClient()
        ModuleClient()
        RepoClient()
        SharedModels()
        Styling()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  Search.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct Search: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        LoggerClient()
        ModuleClient()
        ModuleLists()
        PlaylistDetails()
        RepoClient()
        SharedModels()
        Styling()
        ViewComponents()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  Settings.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

struct Settings: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        BuildClient()
        FluidGradient()
        ModuleClient()
        ModuleLists()
        SharedModels()
        Styling()
        ViewComponents()
        UserSettingsClient()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  VideoPlayer.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

struct VideoPlayer: _Feature {
    var dependencies: any Dependencies {
        Architecture()
        ContentCore()
        LoggerClient()
        PlayerClient()
        SharedModels()
        Styling()
        ViewComponents()
        UserSettingsClient()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  _Feature.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

// MARK: - _Feature

protocol _Feature: Product, Target {}

extension _Feature {
    var path: String? {
        "Sources/Features/\(name)"
    }
}
//
//  CoreDBMacros.swift
//
//
//  Created by ErrorErrorError on 12/28/23.
//
//

struct CoreDBMacros: _Macro {
    var dependencies: any Dependencies {
        SwiftSyntaxMacros()
        SwiftCompilerPlugin()
    }
}
//
//  _Macro.swift
//
//
//  Created by ErrorErrorError on 10/27/23.
//
//

import Foundation

// MARK: - _Macro

protocol _Macro: Macro {}

extension _Macro {
    var path: String? {
        "Sources/Macros/\(name)"
    }
}
//
//  MochiPlatforms.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

import Foundation

struct MochiPlatforms: PlatformSet {
    var body: any SupportedPlatforms {
        SupportedPlatform.macOS(.v12)
        SupportedPlatform.iOS(.v15)
    }
}
//
//  Architecture.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

struct Architecture: _Shared {
    var dependencies: any Dependencies {
        FoundationHelpers()
        ComposableArchitecture()
        LocalizableClient()
        LoggerClient()
    }
}
//
//  CoreDB.swift
//
//
//  Created by ErrorErrorError on 12/28/23.
//
//

// MARK: - CoreDB

struct CoreDB: _Shared {
    var dependencies: any Dependencies {
        CoreDBMacros()
    }
}

// MARK: Testable

extension CoreDB: Testable {
    struct Tests: TestTarget {
        var name: String { "CoreDBTests" }

        var dependencies: any Dependencies {
            CoreDB()
            CustomDump()
        }
    }
}
//
//  FoundationHelpers.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

struct FoundationHelpers: _Shared {}
//
//  JSValueCoder.swift
//
//
//  Created by ErrorErrorError on 11/6/23.
//
//

import Foundation

// MARK: - JSValueCoder

struct JSValueCoder: _Shared {}

// MARK: Testable

extension JSValueCoder: Testable {
    struct Tests: TestTarget {
        var name: String { "JSValueCoderTests" }

        var dependencies: any Dependencies {
            JSValueCoder()
        }
    }
}
//
//  SharedModels.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct SharedModels: _Shared {
    var dependencies: any Dependencies {
        DatabaseClient()
        Tagged()
        ComposableArchitecture()
        Semver()
        JSValueCoder()
    }
}
//
//  Styling.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct Styling: _Shared {
    var dependencies: any Dependencies {
        ViewComponents()
        ComposableArchitecture()
        Tagged()
        SwiftUIBackports()
        UserSettingsClient()
    }
}
//
//  ViewComponents.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

struct ViewComponents: _Shared {
    var dependencies: any Dependencies {
        SharedModels()
        ComposableArchitecture()
        NukeUI()
    }
}
//
//  _Shared.swift
//
//
//  Created by ErrorErrorError on 10/5/23.
//
//

import Foundation

// MARK: - _Shared

protocol _Shared: Product, Target {}

extension _Shared {
    var path: String? {
        "Sources/Shared/\(name)"
    }
}
//
//  Index.swift
//
//
//  Created by ErrorErrorError on 10/4/23.
//
//

import Foundation

let package = Package {
    // Clients
    ModuleClient()

    ModuleLists()
    PlaylistDetails()
    Discover()
    Repos()
    Search()
    Settings()
    VideoPlayer()
    ContentCore()

    MochiApp()
} testTargets: {
    CoreDB.Tests()
    ModuleClient.Tests()
    JSValueCoder.Tests()
}
.supportedPlatforms {
    MochiPlatforms()
}
.defaultLocalization("en")
