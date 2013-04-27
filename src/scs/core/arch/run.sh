#!/bin/sh
echo "STARTING RUN.SH"
#export LUA_PATH="../../../?.lua;/usr/share/lua/5.1/?.lua;$LUA_PATH"
#export IDL_HOME="/home/airton/idl/"
#export IDL_PATH="/home/airton/idl/"

if [ -z $ARCH_HOME]; then
  export ARCH_HOME="`pwd`/../../../../"
fi

if [ -z $IDL_PATH]; then
  export IDL_PATH="${ARCH_HOME}idl/"
fi

if [ -z $ARCH_DPDS]; then
  export ARCH_DPDS="/home/airton/scs_dynadapt/src/static/"
fi

if [ -z $LUA_PATH]; then
  #export LUA_PATH="../../../?.lua;/usr/share/lua/5.1/?.lua;${LUA_PATH}"
  export LUA_PATH="/usr/share/lua/5.1/?.lua;../../../?.lua;?.lua;${ARCH_DPDS}?.lua;${LUA_PATH}"
fi


#echo $IDL_PATH
#echo $ARCH_HOME
#echo $LUA_PATH
#if [ -z "$SCS_HOME" ]; then
#	SCS_HOME="../../../../"
#	cd $SCS_HOME
#	export SCS_HOME="`pwd`"
#	cd -
#	echo "ATTENTION: Using the SCS_HOME system variable as $SCS_HOME"
#fi
#OPENBUS_BIN=${OPENBUS_HOME}/core/bin
#OPENBUS_CONF=${OPENBUS_HOME}/core/conf
#if [ -r ${OPENBUS_CONF}/config ]; then
#  . ${OPENBUS_CONF}/config
#fi
#lua -lluarocks.require ../../utils/debuglua.lua repostart.lua "$@" 2>repo.err >repo.log
echo "STARTING DEPLOYER SCRIPT"
#lua ../../../scs/core/arch/start_deployer.lua "$@" 2>repo.err >repo.log
#lua start_deployer.lua 2>error.log >deployer.log
lua start_deployer.lua 1>out.txt 2>error.log

