# http_archive(
#     name = "com_google_protobuf",
#     patch_args = [
#         "-p1",
#     ],
#     patches = [
#         "//3rd:com_google_protobuf-3.19.1.patch",
#     ],
#     sha256 = "87407cd28e7a9c95d9f61a098a53cf031109d451a7763e7dd1253abf8b4df422",
#     strip_prefix = "protobuf-3.19.1",
#     urls = [
#         "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.19.1.tar.gz",
#     ],
# )

# load(
#     "@com_google_protobuf//:protobuf_deps.bzl",
#     "protobuf_deps",
# )

# protobuf_deps()
