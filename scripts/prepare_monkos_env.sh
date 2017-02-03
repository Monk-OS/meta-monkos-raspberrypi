#!/bin/sh

# make sure that we are sourcing this script
if [ "$0" = "${BASH_SOURCE}" ]; then
  echo -e "  The Script need to be sourced as follows"
  echo -e "  . $0 \nor \n  source $0"
  exit 1
fi

# make sure that you are running in a bash prompt
if [ -z "$BASH" ]; then
  echo -e "Please use a bash shell\n"
  return 1
fi

# make sure that you are not root while sourcing this script
if [ "$(whoami)" = "root" ]; then
  echo -e "You are runing this script as root. Please exit from root and run the script"
  return 1
fi

SCRIPTS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE}")")"
HOME_DIR="$(readlink -f "$(dirname "${BASH_SOURCE}")")"

. ${SCRIPTS_DIR}/dependent_layers.sh
for _layer in "${DEPENDENT_LAYERS[@]}"; do
  if [ ! -d "${_layer}" ] ;then
    echo "Error: ${_layer} is not present which is required for building the monkos"
    echo "Try doing a repo sync or checkout a fresh copy"
    return 1
  fi
done
unset DEPENDENT_LAYERS

# list the supported machines
while [ -z "$MACHINE" ]; do
  _options=$(ls -1 meta-raspberrypi/conf/machine/*.conf | sed 's|.*/\(.*\)\.conf|\1|' 2>/dev/null)
  _options_count=`echo ${_options} | wc -w`
  PS3="Please enter your choice of machine [1..${_options_count}]: "
  select _option in `echo $_options`; do
    if [ -z "${_option}" ]; then
      echo "Invalid choice"
    else
      MACHINE=$(echo ${_option})
      break;
    fi
  done
  unset PS3 _options_count _options _option
done

TEMPLATECONF=${HOME_DIR}/meta-monkos-raspberrypi/templates

_build_dir=build-${MACHINE}

. meta-monkos/scripts/prepare_monkos_env.sh ${_build_dir}

unset SCRIPTS_DIR TEMPLATECONF _build_dir
