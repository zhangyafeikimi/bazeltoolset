# buildifier: disable=module-docstring
load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    "CPP_COMPILE_ACTION_NAME",
    "C_COMPILE_ACTION_NAME",
)
load(
    "@bazel_tools//tools/cpp:toolchain_utils.bzl",
    "find_cpp_toolchain",
)

###################################################################
CC_RULE_KINDS = [
    "cc_binary",
    "cc_import",
    "cc_library",
    "cc_proto_library",
    "cc_shared_library",
    "cc_static_library",
    "cc_test",
]

DISABLED_FEATURES = [
    "module_maps",
]

C_SRC_EXTENSIONS = [
    "c",
]

CC_SRC_EXTENSIONS = [
    "cc",
    "cpp",
    "cxx",
]

UNKNOWN_HDR_EXTENSIONS = [
    "h",
    "inl",
    "inc",
]

CC_HDR_EXTENSIONS = [
    "hpp",
    "ipp",
    "hh",
    "hxx",
]

# https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html
# https://github.com/llvm/llvm-project/blob/main/clang/include/clang/Basic/LangStandards.def
C_STD_FLAGS = [
    "-std=c89",
    "-std=c90",
    "-std=c99",
    "-std=c9x",
    "-std=c11",
    "-std=c1x",
    "-std=c17",
    "-std=c18",
    "-std=c23",
    "-std=c2x",
    "-std=c2y",
    "-std=iso9899:1990",
    "-std=iso9899:199409",
    "-std=iso9899:1999",
    "-std=iso9899:199x",
    "-std=iso9899:2011",
    "-std=iso9899:201x",
    "-std=iso9899:2017",
    "-std=iso9899:2018",
    "-std=iso9899:2024",
    "-std=gnu89",
    "-std=gnu90",
    "-std=gnu99",
    "-std=gnu9x",
    "-std=gnu11",
    "-std=gnu1x",
    "-std=gnu17",
    "-std=gnu18",
    "-std=gnu23",
    "-std=gnu2x",
    "-std=gnu2y",
]

CC_STD_FLAGS = [
    "-std=c++98",
    "-std=c++03",
    "-std=c++11",
    "-std=c++0x",
    "-std=c++14",
    "-std=c++1y",
    "-std=c++17",
    "-std=c++1z",
    "-std=c++20",
    "-std=c++2a",
    "-std=c++23",
    "-std=c++2b",
    "-std=c++26",
    "-std=c++2c",
    "-std=gnu++98",
    "-std=gnu++03",
    "-std=gnu++11",
    "-std=gnu++0x",
    "-std=gnu++14",
    "-std=gnu++1y",
    "-std=gnu++17",
    "-std=gnu++1z",
    "-std=gnu++20",
    "-std=gnu++2a",
    "-std=gnu++23",
    "-std=gnu++2b",
    "-std=gnu++26",
    "-std=gnu++2c",
]

###################################################################
CDInfo = provider(
    doc = "",
    fields = [
        "all_cds",
    ],
)

###################################################################
def _post_process_flags(flags):
    # An ugly trick for macOS.
    if "DEBUG_PREFIX_MAP_PWD=." in flags:
        flags.remove("DEBUG_PREFIX_MAP_PWD=.")
    if "-isysroot" in flags:
        flags.remove("-isysroot")
    if "__BAZEL_XCODE_SDKROOT__" in flags:
        flags.remove("__BAZEL_XCODE_SDKROOT__")

    # Convert GCC flags to their equivalent Clang flags.
    for i, flag in enumerate(flags):
        if flag == "-fno-canonical-system-headers":
            flags[i] = "-no-canonical-prefixes"
        elif flag == "-Wunused-but-set-parameter":
            flags[i] = "-Wunused-parameter"
    return flags

def _get_flags(file, target, ctx, need_compiler = True):
    is_c_src = False
    is_cc_src = False
    is_unknown_hdr = False
    is_cc_hdr = False
    if file.extension in C_SRC_EXTENSIONS:
        is_c_src = True
    elif file.extension in CC_SRC_EXTENSIONS:
        is_cc_src = True
    elif file.extension in UNKNOWN_HDR_EXTENSIONS:
        is_unknown_hdr = True
    elif file.extension in CC_HDR_EXTENSIONS:
        is_cc_hdr = True
    else:
        return None

    compiler_path = None
    flags = []

    # Part 1.
    cc_toolchain = find_cpp_toolchain(ctx)

    # buildifier: disable=native-cc-common
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )
    if is_c_src:
        if need_compiler:
            # buildifier: disable=native-cc-common
            compiler_path = cc_common.get_tool_for_action(
                feature_configuration = feature_configuration,
                action_name = C_COMPILE_ACTION_NAME,
            )

        # buildifier: disable=native-cc-common
        compile_variables = cc_common.create_compile_variables(
            cc_toolchain = cc_toolchain,
            feature_configuration = feature_configuration,
            user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.conlyopts,
        )

        # buildifier: disable=native-cc-common
        command_line = cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = C_COMPILE_ACTION_NAME,
            variables = compile_variables,
        )
    else:
        # Treat all other files as C++.
        if need_compiler:
            # buildifier: disable=native-cc-common
            compiler_path = cc_common.get_tool_for_action(
                feature_configuration = feature_configuration,
                action_name = CPP_COMPILE_ACTION_NAME,
            )

        # buildifier: disable=native-cc-common
        compile_variables = cc_common.create_compile_variables(
            cc_toolchain = cc_toolchain,
            feature_configuration = feature_configuration,
            user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.cxxopts,
        )

        # buildifier: disable=native-cc-common
        command_line = cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = CPP_COMPILE_ACTION_NAME,
            variables = compile_variables,
        )
    if compiler_path:
        flags.append(compiler_path)
    flags.extend(command_line)

    # Part 2.
    # https://bazel.build/rules/lib/builtins/CompilationContext
    # buildifier: disable=native-cc-info
    compilation_context = target[CcInfo].compilation_context
    for define in compilation_context.defines.to_list():
        define = define.replace('"', '\\"')  # Bazel's fault
        flags.append("-D{}".format(define))
    for define in compilation_context.local_defines.to_list():
        define = define.replace('"', '\\"')  # Bazel's fault
        flags.append("-D{}".format(define))
    for include in compilation_context.system_includes.to_list():
        if len(include) == 0:
            include = "."
        flags.append("-isystem{}".format(include))
    for include in compilation_context.includes.to_list():
        if len(include) == 0:
            include = "."
        flags.append("-I{}".format(include))
    for include in compilation_context.quote_includes.to_list():
        if len(include) == 0:
            include = "."
        flags.append("-iquote{}".format(include))
    for include in compilation_context.framework_includes.to_list():
        flags.append("-F{}".format(include))

    # Part 3.
    # https://bazel.build/reference/be/c-cpp
    if hasattr(ctx.rule.attr, "copts"):
        flags.extend(ctx.rule.attr.copts)

    # Part 4.
    if is_c_src:
        if hasattr(ctx.rule.attr, "conlyopts"):
            flags.extend(ctx.rule.attr.conlyopts)
        flags.append("-xc")
    elif is_cc_src:
        if hasattr(ctx.rule.attr, "cxxopts"):
            flags.extend(ctx.rule.attr.cxxopts)
        flags.append("-xc++")
    elif is_unknown_hdr:
        # Guess from std-related flags.
        for flag in reversed(flags):
            if flag in C_STD_FLAGS:
                if hasattr(ctx.rule.attr, "conlyopts"):
                    flags.extend(ctx.rule.attr.conlyopts)
                flags.append("-xc-header")
                break
            elif flag in CC_STD_FLAGS:
                if hasattr(ctx.rule.attr, "cxxopts"):
                    flags.extend(ctx.rule.attr.cxxopts)
                flags.append("-xc++-header")
                break
    elif is_cc_hdr:
        if hasattr(ctx.rule.attr, "cxxopts"):
            flags.extend(ctx.rule.attr.cxxopts)
        flags.append("-xc++-header")

    # Part 5.
    flags.append("-c")
    flags.append(file.path)
    flags = _post_process_flags(flags)
    return flags

###################################################################
def _gen_cd_aspect_impl(target, ctx):
    deps = []
    if hasattr(ctx.rule.attr, "srcs"):
        deps.extend(ctx.rule.attr.srcs)
    if hasattr(ctx.rule.attr, "hdrs"):
        deps.extend(ctx.rule.attr.hdrs)
    if hasattr(ctx.rule.attr, "deps"):
        deps.extend(ctx.rule.attr.deps)

    all_cd_files = []
    all_hdr_files = []
    all_cds = []
    for dep in deps:
        if CDInfo in dep:
            all_cd_files.append(dep[OutputGroupInfo].all_cd_files)
            all_hdr_files.append(dep[OutputGroupInfo].all_hdr_files)
            all_cds.append(dep[CDInfo].all_cds)

    if ctx.rule.kind not in CC_RULE_KINDS:
        all_cd_files = depset(transitive = all_cd_files)
        all_hdr_files = depset(transitive = all_hdr_files)
        all_cds = depset(transitive = all_cds)
        return [
            OutputGroupInfo(
                src_files = [],
                all_cd_files = all_cd_files,
                all_hdr_files = all_hdr_files,
            ),
            CDInfo(
                all_cds = all_cds,
            ),
        ]

    src_files = []
    if hasattr(ctx.rule.attr, "srcs"):
        for src in ctx.rule.attr.srcs:
            src_files.extend(src.files.to_list())
    if hasattr(ctx.rule.attr, "hdrs"):
        for hdr in ctx.rule.attr.hdrs:
            src_files.extend(hdr.files.to_list())
    if ctx.rule.kind == "cc_proto_library":
        for file in target.files.to_list():
            # [proto_file].pb.h
            # [proto_file].pb.cc
            if file.extension in ["h", "cc"]:
                src_files.append(file)

    cds = []
    for file in src_files:
        flags = _get_flags(file, target, ctx, need_compiler = True)
        if flags:
            cds.append(struct(
                command = " ".join(flags),
                file = file.path,
            ))

    cd_file = ctx.actions.declare_file(ctx.label.name + ".cd.json")
    ctx.actions.write(
        content = json.encode(cds),
        output = cd_file,
    )

    all_cd_files = depset([cd_file], transitive = all_cd_files)

    # buildifier: disable=native-cc-info
    all_hdr_files.append(target[CcInfo].compilation_context.headers)
    all_hdr_files = depset(transitive = all_hdr_files)
    all_cds = depset(cds, transitive = all_cds)
    return [
        OutputGroupInfo(
            src_files = src_files,
            all_cd_files = all_cd_files,
            all_hdr_files = all_hdr_files,
        ),
        CDInfo(
            all_cds = all_cds,
        ),
    ]

gen_cd_aspect = aspect(
    implementation = _gen_cd_aspect_impl,
    attr_aspects = [
        "srcs",
        "hdrs",
        "deps",
    ],
    attrs = {
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
    },
    fragments = [
        "cpp",
    ],
)

###################################################################
def _run_clang_tidy_aspect_impl(target, ctx):
    if ctx.rule.kind not in CC_RULE_KINDS:
        return []

    if ctx.label.workspace_root.startswith("external"):
        # Skip targets from other workspace.
        return []

    input_files = []
    if hasattr(ctx.rule.attr, "srcs"):
        for src in ctx.rule.attr.srcs:
            for file in src.files.to_list():
                if file.is_source and (file.extension in C_SRC_EXTENSIONS or file.extension in CC_SRC_EXTENSIONS):
                    input_files.append(file)
    if len(input_files) == 0:
        return []

    _clang_tidy_wrapper = ctx.attr._clang_tidy_wrapper.files.to_list()[0]

    # buildifier: disable=native-cc-info
    compilation_context = target[CcInfo].compilation_context
    output_files = []
    for input_file in input_files:
        flags = _get_flags(input_file, target, ctx, need_compiler = False)
        if not flags:
            continue

        output_file = "_lints/" + target.label.name + "/" + input_file.short_path + ".lint"
        output_file = ctx.actions.declare_file(output_file)
        output_files.append(output_file)

        flags = [
            _clang_tidy_wrapper.path,
            input_file.path,
            output_file.path,
        ] + flags
        ctx.actions.run_shell(
            inputs = depset([input_file, _clang_tidy_wrapper], transitive = [compilation_context.headers]),
            outputs = [output_file],
            command = " ".join(flags),
            mnemonic = "ClangTidyLint",
            progress_message = "Linting {}".format(input_file.short_path),
            use_default_shell_env = True,
        )
    return [
        OutputGroupInfo(clang_tidy = depset(output_files)),
    ]

run_clang_tidy_aspect = aspect(
    implementation = _run_clang_tidy_aspect_impl,
    attr_aspects = [
        "srcs",
        "hdrs",
        "deps",
    ],
    attrs = {
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        "_clang_tidy_wrapper": attr.label(default = Label("//:_clang_tidy_wrapper")),
    },
    fragments = [
        "cpp",
    ],
)
