#!/bin/bash

SIMPLE_CONTAINER_ROOT=container_root

mkdir -p $SIMPLE_CONTAINER_ROOT

gcc -o container_prog container_prog.c

## Subtask 1: Execute in a new root filesystem

cp container_prog $SIMPLE_CONTAINER_ROOT/

# 1.1: Copy any required libraries to execute container_prog to the new root container filesystem 

#The below code for the copy of required libraries from the reference :: https://www.howtogeek.com/441534/how-to-use-the-chroot-command-on-linux/
mkdir -p $SIMPLE_CONTAINER_ROOT/{lib,lib64}
list="$(ldd container_prog | egrep -o '/lib.*\.[0-9]')"
for i in $list; 
do 
    cp  --parents "$i" "${SIMPLE_CONTAINER_ROOT}"; 
done



echo -e "\n\e[1;32mOutput Subtask 2a\e[0m"
# 1.2: Execute container_prog in the new root filesystem using chroot. You should pass "subtask1" as an argument to container_prog

sudo chroot $SIMPLE_CONTAINER_ROOT /container_prog subtask1

echo "__________________________________________"
echo -e "\n\e[1;32mOutput Subtask 2b\e[0m"
## Subtask 2: Execute in a new root filesystem with new PID and UTS namespace
# The pid of container_prog process should be 1
# You should pass "subtask2" as an argument to container_prog

sudo unshare --pid --uts --fork  chroot $SIMPLE_CONTAINER_ROOT /container_prog subtask2

echo -e "\nHostname in the host: $(hostname)"


## Subtask 3: Execute in a new root filesystem with new PID, UTS and IPC namespace + Resource Control
# Create a new cgroup and set the max CPU utilization to 50% of the host CPU. (Consider only 1 CPU core)

mkdir -p /sys/fs/cgroup/task2_cpu
echo 50000 >$task2_cpu/cpu.max

echo "__________________________________________"
echo -e "\n\e[1;32mOutput Subtask 2c\e[0m"
# Assign pid to the cgroup such that the container_prog runs in the cgroup
# Run the container_prog in the new root filesystem with new PID, UTS and IPC namespace
# You should pass "subtask1" as an argument to container_prog

echo $$ > /sys/fs/cgroup/task2_cpu/cgroup.procs
unshare --pid --fork --ipc --uts  chroot $SIMPLE_CONTAINER_ROOT /container_prog subtask3
echo $$ >> /sys/fs/cgroup/cgroup.procs

# Remove the cgroup
rmdir /sys/fs/cgroup/task2_cpu

# If mounted dependent libraries, unmount them, else ignore
