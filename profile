#!/usr/bin/ksh

stty erase ^?

export AIXTHREAD_SCOPE=S

# Set up the search paths:
        PATH=$PATH:.

# Set up the shell environment:
        set -u
        trap "echo 'logout'" 0

# Set up the shell variables:
        EDITOR=vi
        export EDITOR

# Set up shell variables for Oracle

. $HOME/.oraenv
. $HOME/.datapoint_home

# Set up the prompt:
        export HOSTNAME=`hostname`
        PS1='
[${PWD:-}]:
${ORACLE_SID:-}:${LOGNAME:-}@${HOSTNAME:-}>'
        export PS1

# Aliases
alias sp='sqlplus "/ as sysdba"'
alias s='sqlplus "/ as sysdba"'
alias ll='ls -l'


# Add server title to putty bar
echo "\033]0; `hostname | tr '[a-z]' '[A-Z]'` \007\c"

# Aliases for the databases
for DB in `cat $ORATAB|grep -v ^\#|grep -v \*|cut -d":" -f1`
do
   alias $DB='export ORAENV_ASK=NO;\
   export ORACLE_SID='$DB';\
   ORACLE_HOME=`cat $ORATAB |grep \^$ORACLE_SID:|cut -f2 -d':'`; \
   export ORACLE_HOME;\
   export ORACLE_BASE=`echo $ORACLE_HOME | sed -e 's:/product/.*::g'`;\
   export LD_LIBRARY_PATH=$ORACLE_HOME/lib;\
   export SHLIB_PATH=$ORACLE_HOME/lib:/usr/lib;\
   export TNS=$TNS_ADMIN/tnsnames.ora;\
   export TNS_ADMIN=$ORACLE_HOME/network/admin;\
   export ORACLE_PATH=$ORACLE_HOME/bin;\
   export PATH=$ORACLE_HOME/bin:$PATH;\
   export ORACLE_TERM=vt220;\
   export LIB_PATH=$ORACLE_HOME/lib64:$ORACLE_HOME/lib '
   export DATAPOINT_HOME=/oracle/dbtools/datapoint
   export DD_RMAN_AGENT_HOME=/oracle/g01/software/datadomain
done
