#!/bin/bash
#
# Script to install libbitcoin, libwallet, obelisk and sx tools.
#
# Install dependencies and compiles the source code from git for Debian 7 / Ubuntu 13.10.
# For Fedora GNU/Linux distribution aren't tested.
#
# Requires sudo. 
#
# To execute this script, run:
# <sudo bash install-sx.sh>
#
# To read help instructions run:
# <sudo bash install-sx.sh --help>
#
#
set -e
echo
echo " [+] Welcome to S(pesmilo)X(changer)."
echo
sleep 0.3

help_install(){
    if [ "$1" = "help" ]; then
         echo
         echo " [+] Install script help:"
         echo " With this script you can install libbitcoin, libwallet, obelisk and sx tools."
         echo " You can choose betwen a local, custom or a standard (root) install."
         echo " To execute this script and build a local instalation, run:"
         echo " <bash install-sx.sh PATH/...>"
         echo " To execute this script and build a custom instalation type:"
         echo " <sudo bash install-sx.sh /PATH/...>"
         echo " To execute this script and build a standard (root) instalation type:"
         echo " <sudo bash install-sx.sh>"
         echo " The standard path to the source instalation is /usr/local/src."
         echo " The stardard path for the conf files is /etc." 
         echo " Requires sudo."
         echo
         exit
    fi
}

# Custom path:  
custom_install(){
    if [[ "$1" = "/*" ]]; then
        if [ `id -u` = "0" ]; then
            INSTALL_PREFIX=$1
            CONF_DIR=/etc
            RUN_LDCONFIG=
            ROOT_INSTALL=1
        else 
            echo " To setup a custom path path to install run this script as root:"
            echo " <sudo bash install-sx.sh /PATH>"
            echo " Help menu:"
            echo " <bash install-sx.sh help>" 
            exit
        fi    
            
    fi
}

# Local path:
local_install(){
    if [[ -n "$1" ]]; then
        RELATIVE=`pwd`
        INSTALL_PREFIX=$RELATIVE/$1
        CONF_DIR=$INSTALL_PREFIX/etc
        RUN_LDCONFIG=
        ROOT_INSTALL=0
    elif [[ -z "$1" ]]; then
        echo " You need to set a path to build this instalation."
        echo " To setup a local path to install type:"
        echo " <bash install PATH/...>"
        echo " To setup a custom path or to setup a standard (root) path to install,"
        echo " exit with CTRL+c and run this script as root:"
        echo " <sudo bash install-sx.sh /PATH> for a custom install, or:"
        echo " <sudo bash install-sx.sh> for a standard (root) install."
        echo " Help menu:"
        echo " <bash install-sx.sh help>" 
        exit
    fi    
}

# Standard (root) path:
root_install(){
    if [[ -z "$1" ]]; then
        if [ `id -u` = "0" ]; then
        INSTALL_PREFIX=/usr/local
        CONF_DIR=/etc
        RUN_LDCONFIG=ldconfig
        ROOT_INSTALL=1
        elif [ `id -u` != "0" ]; then
            local_path
        fi
    fi
}    

install_dependencies(){
    flavour_id=`cat /etc/*-release | egrep -i "^ID=" | cut -f 2 -d "="`
    echo " Flavour: $flavour_id."
    echo
    if [ "$ROOT_INSTALL" = 1 ]; then
        if [ "$flavour_id" = "debian" ]; then
                sleep 0.5
                apt-get install -y git build-essential autoconf apt-utils libtool libboost-all-dev pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev libconfig++-dev libncurses5-dev
            elif [ "$flavour_id" = "ubuntu" ]; then
                sleep 0.5
                apt-get install -y git build-essential autoconf apt-utils libtool libboost1.49-all-dev pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev libconfig++8-dev libncurses5-dev
#            elif [ "$flavour_id" = "fedora" ]; then
#                sleep 0.5
#                $F_DEPENDENCIES
            else
                echo
                echo " [+] ERROR: No GNU/Linux flavour properly detected: $flavour_id" 1>&2
                echo 
                echo " Please, review the script."
                echo
                exit
            fi
    elif [ "$ROOT_INSTALL" = 1 ]; then
        if [ "$flavour_id" = "debian" ]; then
            sleep 0.5
            sudo apt-get install -y git build-essential autoconf apt-utils libtool libboost-all-dev pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev libconfig++-dev libncurses5-dev
        elif [ "$flavour_id" = "ubuntu" ]; then
            sleep 0.5
            sudo apt-get install -y git build-essential autoconf apt-utils libtool libboost1.49-all-dev pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev libconfig++8-dev libncurses5-dev
#        elif [ "$flavour_id" = "fedora" ]; then
#            sleep 0.5
#            sudo $F_DEPENDENCIES
        else
            echo
            echo " [+] ERROR: No GNU/Linux flavour properly detected: $flavour_id" 1>&2
            echo 
            echo " Please, review the script."
            echo
            exit
        fi
    fi
}

add_src_dir(){
    SRC_DIR=$INSTALL_PREFIX/src
    PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig
    mkdir -p $SRC_DIR
    mkdir -p $PKG_CONFIG_PATH
}

install_libbitcoin(){
    cd $SRC_DIR
    if [ -d "libbitcoin-git" ]; then
        echo
        echo " --> Updating Libbitcoin..."
        echo
        cd libbitcoin-git
        git remote set-url origin https://github.com/spesmilo/libbitcoin.git
        git pull --rebase
    else
        echo
        echo " --> Downloading Libbitcoin from git..."
        echo
        git clone https://github.com/spesmilo/libbitcoin.git libbitcoin-git
    fi
    cd $SRC_DIR/libbitcoin-git
    echo
    echo " --> Beggining build process now...."
    echo
    autoreconf -i
    ./configure --enable-leveldb --prefix $INSTALL_PREFIX
    make
    make install
    $RUN_LDCONFIG
    echo
    echo " o/ Libbitcoin now installed."
    echo
}

install_libwallet(){
    cd $SRC_DIR
    if [ -d "libwallet-git" ]; then
        echo
        echo " --> Updating Libwallet..."
        echo
        cd libwallet-git
        git remote set-url origin https://github.com/spesmilo/libwallet.git
        git pull --rebase
    else
        echo
        echo " --> Downloading Libwallet from git..."
        echo
        git clone https://github.com/spesmilo/libwallet.git libwallet-git
    fi
    cd $SRC_DIR/libwallet-git
    echo
    echo " --> Beggining build process now...."
    echo
    autoreconf -i
    ./configure --prefix $INSTALL_PREFIX
    make
    make install
    $RUN_LDCONFIG
    echo
    echo " o/ Libwallet now installed."
    echo
}

install_obelisk(){
    cd $SRC_DIR
    if [ -d "obelisk-git" ]; then
        echo
        echo " --> Updating Obelisk..."
        echo
        cd obelisk-git
        git remote set-url origin https://github.com/spesmilo/obelisk.git
        git pull --rebase
    else
        echo
        echo " --> Downloading obelisk..."
        echo
        git clone https://github.com/spesmilo/obelisk.git obelisk-git
    fi
    cd $SRC_DIR/obelisk-git
    echo
    echo " --> Beggining build process now..."
    echo
    autoreconf -i
    ./configure --sysconfdir $CONF_DIR --prefix $INSTALL_PREFIX
    make
    make install 
    $RUN_LDCONFIG
    echo
    echo " o/ Obelisk now installed."
    echo
}

install_sx(){
    BIN_DIR=$INSTALL_PREFIX/bin
    rm -rf $BIN_DIR/sx-*
    cd $SRC_DIR
    if [ -d "sx-git" ]; then
        echo
        echo " --> Updating SX..."
        echo
        cd sx-git
        git remote set-url origin https://github.com/spesmilo/sx.git
        git pull --rebase
    else
        echo
        echo " --> Downloading SX from git..."
        echo
        git clone https://github.com/spesmilo/sx.git sx-git
    fi
    cd $SRC_DIR/sx-git
    echo
    echo " --> Beggining build process now...."
    echo
    autoreconf -i
    ./configure --sysconfdir $CONF_DIR --prefix $INSTALL_PREFIX
    make
    make install
    $RUN_LDCONFIG
    echo
    echo " o/ SX tools now installed."
    echo
}

show_finish_install_info(){
    echo " --> Installation finished!"
    if [ "$ROOT_INSTALL" = "1" ]; then
        echo
        echo " Config Files are in: $CONF_DIR"
        echo "   obelisk configuration files: $CONF_DIR/obelisk/*.cfg"
        echo "   sx configuration file: ~/.sx.cfg (see $INSTALL_PREFIX/share/sx/sx.cfg for an example config file)"
        echo 
        echo " Documentation available /usr/local/doc:"
        echo "   libbitcoin doc: $INSTALL_PREFIX/share/doc/libbitcoin/"
        echo "   obelisk doc:    $INSTALL_PREFIX/share/doc/obelisk/"
        echo "   sx doc:         $INSTALL_PREFIX/share/doc/sx/"
        echo
    elif [ "$ROOT_INSTALL" = "0" ]; then
        echo
        echo " Add these lines to your ~/.bashrc"
        echo "   export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib"
        echo "   export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig"
        echo "   export PATH=\$PATH:$INSTALL_PREFIX/bin"
    fi
    echo 
    echo " To setup a obelisk node, you will need obworker and obbalancer daemons running."
    echo " Run <sudo bash $SRC_DIR/obelisk-git/scripts/setup.sh> to create, configure and start the daemons."
    echo
}

case "$1" in
    "/*") custom_install ; install_dependencies ; add_src_dir ; install_libbitcoin ; install_libwallet ; install_obelisk ; install_sx ; show_finish_install_info ;;
    "1") local_install ; install_dependencies ; add_src_dir ; install_libbitcoin ; install_libwallet ; install_obelisk ; install_sx ; show_finish_install_info ;;
    "") root_install ; install_dependencies ; add_src_dir ; install_libbitcoin ; install_libwallet ; install_obelisk ; install_sx ; show_finish_install_info;;
    "--help") help_install ;;
esac
