#!/bin/bash

# Complete this script to deploy external-service and counter-service in two separate containers
# You will be using the conductor tool that you completed in task 3.

# Creating link to the tool within this directory
ln -s ../task3/conductor.sh conductor.sh
ln -s ../task3/config.sh config.sh

# use the above scripts to accomplish the following actions -

# Logical actions to do:
# 1. Build image for the container
# 2. Run two containers say c1 and c2 which should run in background. Tip: to keep the container running
#    in background you should use a init program that will not interact with the terminal and will not
#    exit. e.g. sleep infinity, tail -f /dev/null
# 3. Copy directory external-service to c1 and counter-service to c2 at appropriate location. You can
#    put these directories in the containers by copying them within ".containers/{c1,c2}/rootfs/" directory
# 4. Configure network such that:
#    4.a: c1 is connected to the internet and c1 has its port 8080 forwarded to port 3000 of the host
#    4.b: c2 is connected to the internet and does not have any port exposed
#    4.c: peer network is setup between c1 and c2
# 5. Get ip address of c2. You should use script to get the ip address. 
#    You can use ip interface configuration within the host to get ip address of c2 or you can 
#    exec any command within c2 to get it's ip address
# 6. Within c2 launch the counter service using exec [path to counter-service directory within c2]/run.sh
# 7. Within c1 launch the external service using exec [path to external-service directory within c1]/run.sh
# 8. Within your host system open/curl the url: http://localhost:3000 to verify output of the service
# 9. On any system which can ping the host system open/curl the url: `http://<host-ip>:3000` to verify
#    output of the service

sudo bash conductor.sh build mydebian

sleep 10

sudo bash conductor.sh run mydebian c1 -- sleep infinity &
sudo bash conductor.sh run mydebian c2 -- sleep infinity &

sleep 30
sudo cp -r external-service/. ./.containers/c1/rootfs/external-service
sleep 2
sudo cp -r counter-service/. ./.containers/c2/rootfs/counter-service

sleep 5
sudo bash conductor.sh addnetwork c1 --internet --expose 8080-3000
sudo bash conductor.sh addnetwork c2 --internet
sudo bash conductor.sh peer c1 c2 

sleep 20
c2_ip=$(sudo bash conductor.sh exec c2 ip a | awk '/inet / {split($2, ip, "/"); print ip[1]}' | sed -n '2p')

sleep 20

sudo bash conductor.sh exec c2 bash ./counter-service/run.sh &

sudo bash conductor.sh exec c1 bash  ./external-service/run.sh  "http://$c2_ip:8080/" &
sleep 500