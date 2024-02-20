#!/bin/bash

#要安装的软件包列表
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
#设置Git用户名和邮箱
Git_User_Name="SkybowAlexandra"
Git_User_Email="1973659295@qq.com"
#Git_User_Name=""
#Git_User_Email=""


#开源仓库地址
Vcpkg_Repo="https://github.com/microsoft/vcpkg.git"
Vimplus_Repo="https://github.com/shinlw/vimplus.git"
gcc13_Repo="https://github.com/gcc-mirror/gcc.git"
gdb_Repo="https://github.com/gdb-mirror/gdb.git"


#安装gcc13需要更新GLIBCXX_3.4.32
#sudo add-apt-repository ppa:ubuntu-toolchain-r/test
#sudo apt-get update
#sudo apt-get install --only-upgrade libstdc++6






EXIT_SUCCESS=0
EXIT_FAILURE=1



function log() 
{
    echo -e "\e[32m$@\e[0m"
}

function err()
{
    echo -e "\e[31m$@ \e[0m " >&2
}

function wrn()
{
    echo -e "\033[33m$@\033[0m"
}

function Set_Git_User_And_Email()
{
    # 检查Git_User_Name是否为空
    if [ -z "$Git_User_Name" ]; then
        wrn "Git User Name is not set...."
        return $EXIT_FAILURE
    fi
    # 检查Git_User_Email是否为空
    if [ -z "$Git_User_Email" ]; then
        wrn "Git User Email is not set..."
        return $EXIT_FAILURE
    fi
    #设置git用户和邮箱
    git config --global user.name $Git_User_Name
    if [ $? -ne 0 ]; then
        return $EXIT_FAILURE
    fi
    git config --global user.email $Git_User_Email
    if [ $? -ne 0 ]; then
        return $EXIT_FAILURE
    fi


    return $EXIT_SUCCESS

}




function Instail_Packages()
{
    sudo apt install -y "${packages_to_install[@]}"
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



main()
{

    #if [ "$(id -u)" -ne "0" ]; then
    #    sudo "$0" "$user_dir"     
    #    exit $EXIT_FAILURE
    #fi
    Check_Ubuntu_Version

    sudo apt update
    sudo apt upgrade

    if [ "$?" -eq 0 ]; then
        log "System version check passed..."
    else
        err "The ubuntu version must be greater than 22..."
        exit $EXIT_FAILURE
    fi

    #2.安装软件包
    Instail_Packages
#
    #3.设置Git信息
    Set_Git_User_And_Email
    if [ "$?" -eq 0 ]; then
        log "Set Git User Name and Email Success..."
    else
        wrn "Set Git User Name and Email Failed..."
        exit $EXIT_FAILURE
    fi

    #4.创建目录
    if [ ! -d ~/Softwares ]; then
        mkdir ~/Softwares
    fi
    if [ ! -d ~/Projcts ]; then
        mkdir ~/Projcts
    fi
    #5.克隆仓库
    cd ~/Softwares
    git clone $Vcpkg_Repo




    exit $EXIT_SUCCESS
}

main