#!/bin/bash
#代理ip
http_proxy=http://192.168.1.2:7890

proxy_ip=${http_proxy#http://}  # 移除"http://"
proxy_ip=${proxy_ip%%:*}        # 截取冒号":"之前的部分，即IP地址
proxy_port=${http_proxy##*:}    # 截取冒号":"之后的部分，即端口号
# 输出IP地址和端口
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
)
#设置Git用户名和邮箱
Git_User_Name="SkybowAlexandra"
Git_User_Email="1973659295@qq.com"

#Git_User_Name=""
#Git_User_Email=""

#要安装的C++库列表
Vcpkg_Install_Package=(
    "openssl"
    "boost"
    "sqlite"
    "zlib"
    "cpp-httplib"
    "curl"
)

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
    cd ~/Softwares
    git clone $Vcpkg_Repo "vcpkg"
    cd ~/Softwares/vcpkg
    bash bootstrap-vcpkg.sh
    for package in "${Vcpkg_Install_Package[@]}"; do
     ./vcpkg install $package
    done

    return 0
}


function main()
{
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



    exit $EXIT_SUCCESS
}

main