#! /bin/bash
#

function get_bazel_workspace_dir() {
    local workspace=$PWD
    while true; do
        if [ -f ${workspace}/WORKSPACE ] || [ -f ${workspace}/WORKSPACE.bazel ]; then
            break
        elif [ -z "$workspace" -o "$workspace" = "/" ]; then
            local workspace=$PWD
            break
        fi
        local workspace=${workspace%/*}
    done
    echo $workspace
}

function switch_bazel_bin_dir() {
    local workspace=$(get_bazel_workspace_dir)
    local cwd=$(pwd)
    if [[ $workspace == $HOME/QQMail ]]; then
        if [[ $cwd =~ $workspace/build64_release/ ]]; then
            local dir=$(echo $cwd | sed "s|^$workspace/build64_release/|$workspace/|")
            cd $dir
        elif [[ $cwd =~ $workspace/build64_fastbuild/ ]]; then
            local dir=$(echo $cwd | sed "s|^$workspace/build64_fastbuild/|$workspace/|")
            cd $dir
        else
            local dir=$(echo $cwd | sed "s|^$workspace/|$workspace/build64_release/|")
            if test -d $dir; then
                cd $dir
            else
                local dir=$(echo $cwd | sed "s|^$workspace/|$workspace/build64_fastbuild/|")
                if test -d $dir; then
                    cd $dir
                fi
            fi
        fi
    else
        if [[ $cwd =~ $workspace/bazel-bin/ ]]; then
            local dir=$(echo $cwd | sed "s|^$workspace/bazel-bin/|$workspace/|")
            cd $dir
        else
            local dir=$(echo $cwd | sed "s|^$workspace/|$workspace/bazel-bin/|")
            if test -d $dir; then
                cd $dir
            fi
        fi
    fi
}

alias a=switch_bazel_bin_dir
alias bba='bazel build ...'
alias bta='bazel test ...'
alias bbc='bazel clean'

dir=$(dirname ${BASH_SOURCE[0]})
alias gen_cd=$dir/gen_cd
alias run_clang_tidy=$dir/run_clang_tidy
if test $(uname -s) == Linux; then
    alias run_coverage=$dir/run_coverage
    alias run_valgrind=$dir/run_valgrind
fi
unset dir
