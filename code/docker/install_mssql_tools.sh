#!/usr/bin/env bash
. "$( dirname "${BASH_SOURCE[0]}" )/common.sh"

set -euo pipefail

common::get_colors
declare -a packages

: "${INSTALL_MSSQL_CLIENT:?Should be true or false}"


function install_mssql_tools() {
    # Install MsSQL tools from Microsoft repositories
    if [[ ${INSTALL_MSSQL_CLIENT:="true"} != "true" ]]; then
        echo
        echo "${COLOR_BLUE}Skip installing mssql tools${COLOR_RESET}"
        echo
        return
    fi
    packages=("mssql-tools")

    #common::import_trusted_gpg "EB3E94ADBE1229CF" "microsoft"

    echo
    echo "${COLOR_BLUE}Installing mssql tools${COLOR_RESET}"
    echo

    #echo "deb [arch=amd64,arm64] https://packages.microsoft.com/debian/$(lsb_release -rs)/prod $(lsb_release -cs) main" > \
    #    /etc/apt/sources.list.d/mssql-tools-release.list
	#ACCEPT_EULA='Y'
    ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive \
	apt-get update -yqq
	ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive \
    apt-get upgrade -yqq
	ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive \
	apt-get -yqq install --no-install-recommends "${packages[@]}"
    rm -rf /var/lib/apt/lists/*
    apt-get autoremove -yqq --purge
    apt-get clean && rm -rf /var/lib/apt/lists/*
}

install_mssql_tools "${@}"
