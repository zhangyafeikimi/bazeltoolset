load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)

licenses(["notice"])

COPTS = [
    "-std=c++17",
    "-w",
    "-pthread",
    "-fstrict-aliasing",
    "-DHAVE_POSIX_REGEX=1",
    "-DHAVE_STD_REGEX=1",
    "-DHAVE_STEADY_CLOCK=1",
]

LINKOPTS = [
    "-pthread",
]

cc_library(
    name = "benchmark",
    srcs = glob(
        [
            "src/**/*.cc",
            "src/**/*.h",
        ],
        exclude = [
            "src/benchmark_main.cc",
        ],
    ),
    hdrs = glob([
        "include/**",
    ]),
    copts = COPTS,
    includes = [
        "include",
    ],
    linkopts = LINKOPTS,
    linkstatic = True,
    visibility = [
        "//visibility:public",
    ],
)

cc_library(
    name = "benchmark_main",
    srcs = [
        "src/benchmark_main.cc",
    ],
    hdrs = glob([
        "include/**",
    ]),
    copts = COPTS,
    includes = [
        "include",
    ],
    linkopts = LINKOPTS,
    linkstatic = True,
    visibility = [
        "//visibility:public",
    ],
    deps = [
        ":benchmark",
    ],
)
