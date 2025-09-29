# http_archive(
#     name = "com_google_googletest",
#     build_file = "//3rd:com_google_googletest-1.15.2.BUILD",
#     patch_cmds = [
#         # #include "src/xxx.h" -> #include "xxx.h"
#         # So that less includes are required.
#         "find . -name '*.cc' | xargs sed -i'.bak' 's/include \"src\\//include \"/g'",
#         "find . -name '*.cc.bak' | xargs rm",
#     ],
#     sha256 = "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926",
#     strip_prefix = "googletest-1.15.2",
#     urls = [
#         "https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz",
#     ],
# )
