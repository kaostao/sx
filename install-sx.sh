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

help_install(){
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
}


function prompt_user(){
    # Prompt user before continuing
    read -p "Would you like to continue the installation? [Y/n] "
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Install aborted."
        exit
    fi
}

# Custom path:  
custom_root_install(){
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
relative_local_install(){
    RELATIVE=`pwd`
    INSTALL_PREFIX="$RELATIVE/$1"
    CONF_DIR="$INSTALL_PREFIX/etc"
    RUN_LDCONFIG=
    ROOT_INSTALL=0
}

absolute_local_install(){
    INSTALL_PREFIX=$1
    CONF_DIR="$INSTALL_PREFIX/etc"
    RUN_LDCONFIG=
    ROOT_INSTALL=0
}

# Standard (root) path:
root_install(){
    if [ `id -u` = "0" ]; then
        INSTALL_PREFIX=/usr/local
        CONF_DIR=/etc
        RUN_LDCONFIG=ldconfig
        ROOT_INSTALL=1
    else
        echo
        echo "[+] ERROR: This script must be run as root." 1>&2
        echo
        echo "<sudo bash install-sx.sh>"
        echo
        exit
    fi
}    

D_DEPENDENCIES="\
git build-essential autoconf apt-utils libtool libboost-all-dev \
pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev \
libconfig++-dev libncurses5-dev"

U_DEPENDENCIES="\
git build-essential autoconf apt-utils libtool libboost1.49-all-dev \
pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev \
libconfig++8-dev libncurses5-dev"

F_DEPENDENCIES=

install_dependencies(){
    flavour_id=`cat /etc/*-release | egrep -i "^ID=" | cut -f 2 -d "="`
    echo " Flavour: $flavour_id."
    echo
    if [ "$flavour_id" = "debian" ]; then
        INSTALL_COMMAND="sudo apt-get install -y $D_DEPENDENCIES"
    elif [ "$flavour_id" = "ubuntu" ]; then
        INSTALL_COMMAND="sudo apt-get install -y $U_DEPENDENCIES"
    #elif [ "$flavour_id" = "fedora" ]; then
    #   INSTALL_COMMAND="...??? $F_DEPENDENCIES"
    else
        echo
        echo " [+] ERROR: No GNU/Linux flavour properly detected: $flavour_id" 1>&2
        echo 
        echo " Please, review the script."
        echo
        exit
    fi

    if [ "$ROOT_INSTALL" = 1 ]; then
        $INSTALL_COMMAND
    else
        echo "Please run this command to install the neccessary dependencies before continuing."
        echo
        echo "  $INSTALL_COMMAND"
        echo
        prompt_user
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
    echo
    echo "Config Files are in: $CONF_DIR"
    echo "  obelisk configuration files: $CONF_DIR/obelisk/*.cfg"
    echo "  sx configuration file: ~/.sx.cfg (see $INSTALL_PREFIX/share/sx/sx.cfg for an example config file)"
    echo 
    echo "Documentation available /usr/local/doc:"
    echo "  libbitcoin doc: $INSTALL_PREFIX/share/doc/libbitcoin/"
    echo "  obelisk doc:    $INSTALL_PREFIX/share/doc/obelisk/"
    echo "  sx doc:         $INSTALL_PREFIX/share/doc/sx/"
    echo
    echo "To setup a obelisk node, you will need obworker and obbalancer daemons running."
    echo "Run <sudo bash $SRC_DIR/obelisk-git/scripts/setup.sh> to create, configure and start the daemons."
    echo
    echo "You may need to reload your shell before continuing."
}

if [ "$1" = "--help" ] || [ "$1" == "-h" ]; then
    help_install
    exit
fi

if [ "$#" == "1" ]; then
    # Perform install to use specified path.
    if [[ $1 =~ ^\/home ]]; then
        # Install without needing root (path begins with /home)
        absolute_local_install $1
    elif [[ $1 =~ ^\/ ]]; then
        # Install needing root (path begins with / but not /home)
        custom_root_install $1
    else
        # Relative path: root not needed
        relative_local_install $1
    fi

    if [ "$ROOT_INSTALL" = "0" ]; then
        PROFILE_FILE=~/.bashrc
    else
        PROFILE_FILE=/etc/profile
    fi

    EXPORT_LD="export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib"
    EXPORT_PKG="export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig"
    EXPORT_PATH="export PATH=\$PATH:$INSTALL_PREFIX/bin"

    # If variables are not in your $PROFILE_FILE then adds them.
    # We check if they're there already by looking for the "Added by..." line
    if ! grep -q "Added by install-sx" $PROFILE_FILE; then
        echo "# Added by install-sx" >> $PROFILE_FILE
        echo "$EXPORT_LD" >> $PROFILE_FILE
        echo "$EXPORT_PKG" >> $PROFILE_FILE
        echo "$EXPORT_PATH" >> $PROFILE_FILE
    elif [ "$ROOT_INSTALL" = "1" ]; then
        # TODO: Should use sed to add path if it doesn't exist (hard mode).
        echo "Previous values detected. They may need manual updating if"
        echo "creating multiple custom path installs on the same system."
        echo
        echo "  $EXPORT_LD"
        echo "  $EXPORT_PKG"
        echo "  $EXPORT_PATH"
        echo
        echo "Patches to handle this case are welcome."
        echo
        prompt_user
    fi

    # Actually run exports do script can continue running.
    $EXPORT_LD
    $EXPORT_PKG
    source $PROFILE_FILE
else
    # Default root install
    root_install
fi

install_dependencies
add_src_dir
install_libbitcoin
install_libwallet
install_obelisk
install_sx
show_finish_install_info

