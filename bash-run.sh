
filename="/var/lib/jenkins/futurelabgpuusers"

echo "#!/bin/bash" >> docker/user.sh
echo "set -e" >> docker/user.sh
echo "useradd -m -d /home/$USERNAME -G ssh $USERNAME -s /bin/bash" >> docker/user.sh
echo "echo \"$USERNAME:$userPass\" | chpasswd" >> docker/user.sh
echo "echo \"$USERNAME ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers" >> docker/user.sh

sed -i "1s/.*/FROM nvidia\/cuda:${cuda}-base-ubuntu16.04/" docker/Dockerfile

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

index=0

while IFS=' ' read -r name port version; do
    usedPorts["$index"]="$port"
    index=$((index+1))
done < "$filename"

iterPort=2233
while :
do
    containsElement "$iterPort" "${usedPorts[@]}"
    if [ $? -ne 0 ]; 
    then
    	port=$iterPort
        break
	fi
    iterPort=$((iterPort+1))
done

echo "$USERNAME $port $cuda" >> $filename

echo "#######################################"
echo "# Here is the Credentials for New User "
echo "# user: $USERNAME"
echo "# port: " $port 
echo "# pass: $userPass"
echo "# Cuda Version: $cuda"
echo "#######################################"

echo "version: '3'"  >> docker-compose.yml

echo "services:"  >> docker-compose.yml
echo "    server:"  >> docker-compose.yml
echo "        build:"  >> docker-compose.yml
echo "            context: ./docker"  >> docker-compose.yml
echo "        image: nvidia/cuda:${cuda}-base-ubuntu16.04-futurelab-${username}" >> docker-compose.yml
echo "        hostname: futurelab"   >> docker-compose.yml

buildsuccess=$(sudo docker-compose build | sed -n 'x;$p' | awk '{print $1}{print $2}')

if [ "$buildsuccess" != "Successfully
built" ]; then
   exit 100
fi
