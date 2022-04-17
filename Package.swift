// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Supabase",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v11),
    .tvOS(.v11),
    .watchOS(.v3),
  ],
  products: [
    .library(
      name: "Supabase",
      targets: ["Supabase"]
    )
  ],
  dependencies: [
    .package(name: "GoTrue", url: "https://github.com/supabase/gotrue-swift.git", .exact("0.0.3")),
    .package(
      name: "SupabaseStorage", url: "https://github.com/supabase/storage-swift.git", .exact("0.0.1")
    ),
    .package(
      name: "Realtime", url: "https://github.com/supabase/realtime-swift.git", .exact("0.0.1")),
    .package(
      name: "PostgREST", url: "https://github.com/supabase/postgrest-swift", .exact("0.0.2")),
  ],
  targets: [
    .target(
      name: "Supabase",
      dependencies: ["GoTrue", "SupabaseStorage", "Realtime", "PostgREST"]
    ),
    .testTarget(
      name: "SupabaseTests",
      dependencies: ["Supabase"]
    ),
  ]
)
