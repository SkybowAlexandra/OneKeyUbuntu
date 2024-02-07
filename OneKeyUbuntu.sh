#!/bin/bash
packages_to_install=(
    "ssh"
    "git"
    "gcc"
    "g++"
    "make"
    "cppcheck"
    "cmake"
    "docker"
    "net-tools"
    "tree"
    "ninja-build"
    "python3"
    "python3-dev"
    "curl"
)

EXIT_SUCCESS=0
EXIT_FAILURE=1

Instail_Packages()
{
    apt install -y "${packages_to_install[@]}"
}

# 检查版本号是否大于22
function Check_Ubuntu_Version()
{
    ubuntu_version=$(lsb_release -rs)
    ubuntu_version_no_dot=$(echo "$ubuntu_version" | tr -d '.')
    if [ "$ubuntu_version_no_dot" -gt 22 ]; then
        return 0
    else
        return 1
    fi
}

log() 
{
    local message="$1"
    echo -e "\e[32m$message\e[0m"
}

err()
{
    local message="$1"
    echo -e "\e[31m$message \e[0m " >&2
}



main()
{
    if [ "$(id -u)" -ne "0" ]; then
        sudo "$0" "$@"
        exit $?
    fi

    Check_Ubuntu_Version
    if [ "$?" -eq 0 ]; then
        log "System version check passed..."
    else
        err "The ubuntu version must be greater than 22..."
        exit $EXIT_FAILURE
    fi

    apt update -y
    apt upgrade -y
    #安装软件包
    Instail_Packages

    exit $EXIT_SUCCESS
}

main "$@"