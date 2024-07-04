load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@rules_cc//cc:defs.bzl", "objc_library")
load("@rules_cc//cc:defs.bzl", "cc_library")
load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_bundle")
# load(
#     "@rules_xcodeproj//xcodeproj:defs.bzl",
#     "top_level_target",
#     "xcodeproj",
# )

BRIDGING_HEADER = "Sources/StrokeMatching-Bridging-Header.h"

apple_resource_bundle(
  name = "MainResources",
  resources = glob(["Resources/**"]),
)

swift_library(
    name = "lib",
    srcs = glob(["Sources/*.swift"]),
    copts = [
        "-import-objc-header",
        BRIDGING_HEADER,
        # "-cxx-interoperability-mode=default"
    ],
    deps = [":objc_lib"],
    data = [":MainResources"],
)

objc_library(
    name = "objc_lib",
    srcs = glob(["Sources/*.mm", "Sources/*.h"]),
    hdrs = [],
    deps = [":cpp_lib"],
)

cc_library(
  name = "cpp_lib",
  srcs = glob(["Sources/*.cpp", "Sources/*.hpp"]),
  hdrs = [],
)

ios_application(
    name = "StrokeMatchingApp",
    bundle_id = "build.bazel.stroke-matching-iOS",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = ["Resources/Info.plist"],
    minimum_os_version = "15.0",
    visibility = ["//visibility:public"],
    deps = [":lib"],
    resources = glob(["Resources/*.drawing"]),
)

# xcodeproj(
#     name = "xcodeproj",
#     project_name = "StrokeMatchingApp",
#     tags = ["manual"],
#     top_level_targets = [
#         top_level_target(":StrokeMatchingApp", target_environments = ["device", "simulator"]),
#     ],
# )