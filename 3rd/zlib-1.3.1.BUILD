load(
    "@rules_cc//cc:defs.bzl",
    "cc_library",
)

licenses(["notice"])

cc_library(
    name = "zlib",
    srcs = [
        "adler32.c",
        "compress.c",
        "crc32.c",
        "crc32.h",
        "deflate.c",
        "deflate.h",
        "gzclose.c",
        "gzguts.h",
        "gzlib.c",
        "gzread.c",
        "gzwrite.c",
        "infback.c",
        "inffast.c",
        "inffast.h",
        "inffixed.h",
        "inflate.c",
        "inflate.h",
        "inftrees.c",
        "inftrees.h",
        "trees.c",
        "trees.h",
        "uncompr.c",
        "zutil.c",
        "zutil.h",
    ],
    hdrs = [
        "zconf.h",
        "zlib.h",
    ],
    copts = [
        "-std=c11",
        "-w",
    ],
    includes = [
        ".",
    ],
    linkstatic = True,
    local_defines = [
        "HAVE_HIDDEN=1",
    ] + select({
        "@platforms//os:linux": [
            "_LARGEFILE64_SOURCE=1",
        ],
        "//conditions:default": [],
    }),
    visibility = [
        "//visibility:public",
    ],
)
