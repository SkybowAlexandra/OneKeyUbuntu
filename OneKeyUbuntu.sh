#!/bin/bash
#代理ip
http_proxy=http://192.168.1.2:7890

proxy_ip=${http_proxy#http://}  # 移除"http://"
proxy_ip=${proxy_ip%%:*}        # 截取冒号":"之前的部分，即IP地址
proxy_port=${http_proxy##*:}    # 截取冒号":"之后的部分，即端口号
# 输出代理IP地址和端口
echo "代理IP地址: $proxy_ip"
echo "代理端口: $proxy_port"

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
    "manpages-zh"
)
#设置Git用户名和邮箱
Git_User_Name="SkybowAlexandra"
Git_User_Email="1973659295@qq.com"

#Git_User_Name=""
#Git_User_Email=""

#要安装的C++库列表
Vcpkg_Install_Package=(
    "openssl"
    "sqlite3"
    "jsoncpp"
    "opencv"
    "zlib"
    "cpp-httplib"
    "curl"
)

#开源仓库地址
Vcpkg_Repo="https://github.com/microsoft/vcpkg.git"
Vimplus_Repo="https://github.com/shinlw/vimplus.git"
gcc13_Repo="https://github.com/gcc-mirror/gcc.git"
Cmake_Repo="https://github.com/Kitware/CMake.git"


#安装gcc13需要更新GLIBCXX_3.4.32
#sudo add-apt-repository ppa:ubuntu-toolchain-r/test
#sudo apt-get update
#sudo apt-get install --only-upgrade libstdc++6


#脚本退出标志位
EXIT_SUCCESS=0
EXIT_FAILURE=1

Script_dir=$(pwd)

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
        wrn "Git用户名未设置...."
        return $EXIT_FAILURE
    fi
    # 检查Git_User_Email是否为空
    if [ -z "$Git_User_Email" ]; then
        wrn "Git用户邮箱未设置..."
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

function Set_Network_Proxy()
{
    # 检查是否提供了http_proxy环境变量
    if [ -z "$http_proxy" ]; then
        wrn "未设置http代理服务器,可能会出现下载失败"
        return 1
    fi
    # 检查代理地址是否可用
    curl -x "$http_proxy" -I "www.google.com" --max-time 10 > /dev/null
    if [ $? -ne 0 ]; then
        wrn "http代理地址不可用,不使用代理服务器..."
        return 1
    fi

    git config --global http.proxy $http_proxy
    git config --global https.proxy $http_proxy
    export http_proxy=$http_proxy
    export https_proxy=$http_proxy
    log "http代理设置成功..."
    return 0

}

function Install_Vcpkg()
{   
    #安装依赖
    sudo apt install -y pkg-config autoconf
    # 进入软件目录
    cd ~/Softwares || return 1
    # 如果 vcpkg 目录已经存在，则更新代码，否则克隆代码
    if [ -d "vcpkg" ]; then
        log "vcpkg目录存在"
        cd vcpkg || return 1
        git pull || return 1
    else
        log "vcpkg目录不存在"
        git clone "$Vcpkg_Repo" "vcpkg" || return 1
        cd vcpkg || return 1
    fi
    #启动 vcpkg 安装
    ./bootstrap-vcpkg.sh || return 1
    # 安装指定的包，并记录日志
    for package in "${Vcpkg_Install_Package[@]}"; do
        ./vcpkg install "$package" | tee "$Script_dir/vcpkg_install.log" || {
            err "安装 $package 失败"
        }
    done
    return 0
}
cleanup() {
    err "强制结束脚本..."
    # 在这里添加任何你想要执行的清理操作
    exit $EXIT_FAILURE
}


function main()
{
    # 设置捕获 Ctrl+C 信号的处理函数
    trap cleanup SIGINT
    
    #1.检查系统
    Check_Ubuntu_Version
    if [ "$?" -eq 0 ]; then
        log "Ubuntu系统版本检查通过..."
    else
        log "Ubuntu系统版本检查不通过,请升级到22.04以上版本..."
        exit $EXIT_FAILURE
    fi
    #2.安装软件包
    Instail_Packages

    #3.设置网络代理
    Set_Network_Proxy
    #4.更新系统
    sudo apt update
    sudo apt upgrade



    #5.设置Git信息
    Set_Git_User_And_Email
    if [ "$?" -eq 0 ]; then
        log "设置Git用户名和邮箱成功..."
    else
        wrn "设置Git用户名和邮箱失败..."
        exit $EXIT_FAILURE
    fi

    #6.创建目录
    if [ ! -d ~/Softwares ]; then
        mkdir ~/Softwares
    fi
    if [ ! -d ~/Projcts ]; then
        mkdir ~/Projcts
    fi
    #5.克隆仓库
    Install_Vcpkg


    log "一键安装Ubuntu环境”脚本执行完毕..."
    exit $EXIT_SUCCESS
}

main