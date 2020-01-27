#!/usr/bin/env bash

# Apply salt states to install pavedroad development environment
# Apply states in masterless mode using salt-call

showgrains=
loglevel=
dryrun=
output=
verbose=

while getopts "gl:no:v:" opt; do
  case ${opt} in
    g ) showgrains=1
      ;;
    l ) loglevel="--log-level=${OPTARG}"
      ;;
    n ) dryrun="test=True"
      ;;
    o ) output="--state-output=${OPTARG}"
      ;;
    v ) verbose="--state-verbose=${OPTARG}"
      ;;
    \? ) echo "Usage: "$0" [-g] [-n] [-l <loglevel>] [-o <output>] [-v <verbose>]"
        echo "-g            - show grains.items"
        echo "-l <loglevel> - set --log-level"
        echo "-n            - perform dry run"
        echo "-o <output>   - set --state-output"
        echo "-v <verbose>  - set --state-verbose"
        exit 1
      ;;
  esac
done

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

export PYTHONWARNINGS="ignore::DeprecationWarning"

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

if (cat /proc/1/cgroup | grep docker) >& /dev/null ; then
    docker=True
else
    docker=False
fi

# associative arrays not available in bash before version 4
# thus reverting from associative array to two parallel arrays
grain_names=(
realuser
realgroup
homedir
saltenv
docker
)

grain_values=(
"$(id -un ${SUDO_UID})"
"$(id -gn ${SUDO_UID})"
"$(eval echo ~$(id -un ${SUDO_UID}))"
dev
"${docker}"
)

cat << EOF
Configuring grains for the development kit salt states
Running salt in masterless mode: Ignore the following messages:
    [INFO    ] Although 'dmidecode' was found in path ...
    [ERROR   ] Got insufficient arguments ...

EOF

for i in ${!grain_names[@]}; do
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.setval "${grain_names[$i]}" "${grain_values[$i]}"
done

cat << EOF

Applying salt states for the developemt kit now
Please be patient as this process may take 5 to 10 minutes
To see progress: tail -f pr-root/var/log/salt/minion
Running salt in masterless mode: Ignore the following messages:
    [INFO    ] Although 'dmidecode' was found in path ...
    [ERROR   ] Got insufficient arguments ...

EOF

salt-call \
    --config-dir "${saltdir}/config/" \
    --pillar-root  "${saltdir}/pillar/" \
    --file-root  "${saltdir}/states/" \
    ${loglevel} ${output} ${verbose} \
    state.highstate ${dryrun} 2>/dev/null

if [ ${showgrains} ]; then
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.items
fi
