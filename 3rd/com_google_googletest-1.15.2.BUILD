load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)

licenses(["notice"])

COPTS = [
    "-std=c++17",
    "-w",
    "-pthread",
]

LINKOPTS = [
    "-pthread",
]

cc_library(
    name = "gtest",
    srcs = glob(
        [
            "googlemock/src/**",
            "googletest/src/**",
        ],
        exclude = [
            "googlemock/src/gmock-all.cc",
            "googlemock/src/gmock_main.cc",
            "googletest/src/gtest-all.cc",
            "googletest/src/gtest_main.cc",
        ],
    ),
    hdrs = glob([
        "googlemock/include/gmock/**/*.h",
        "googletest/include/gtest/**/*.h",
    ]),
    copts = COPTS,
    includes = [
        "googlemock/include",
        "googletest/include",
    ],
    linkopts = LINKOPTS,
    linkstatic = True,
    visibility = [
        "//visibility:public",
    ],
)

cc_library(
    name = "gtest_main",
    srcs = [
        "googlemock/src/gmock_main.cc",
    ],
    copts = COPTS,
    linkopts = LINKOPTS,
    linkstatic = True,
    visibility = [
        "//visibility:public",
    ],
    deps = [
        ":gtest",
    ],
)
