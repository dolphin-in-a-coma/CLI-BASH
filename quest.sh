#!/usr/bin/env bash

sudo echo "Let's start the quest"

# Stage 1 - Delete a file

# tsk -k eugenartemovich@gmail.com
# message=$(tsk -k eugenartemovich@gmail.com 2>&1)

tsk -k $1
message=$(tsk -k $1 2>&1)
message=($message)
key1=${message[-1]}
tsk -s 1 -k $key1
rm -f -- -r
tsk -s 1 -k $key1 -c
message=$(tsk -s 1 -k $key1 -c 2>&1)
message=($message)
key2=${message[-1]}

# Stage 2 - Create lost files

tsk -s 2 -k $key2
files=$(ls /var/log/loggen/*.log)
files=($files)
for file in ${files[*]}; do 
    grep "\[404\]" $file | sort -u | while read LINE; do
        line=($LINE);
        address=${line[3]};
        acces=${line[2]};
        acces=${acces:1:3};
        size=${line[-1]};
        size=${size:1};
        folder=$(echo $address| rev);
        folder=$(echo ${folder#*/}| rev);
        mkdir -p $folder;
        sudo touch $address;
        sudo truncate -s $size $address;
        sudo chmod $acces $address
    done;
done;
tsk -s 2 -k $key2 -c
message=$(tsk -s 2 -k $key2 -c 2>&1)
message=($message)
key3=${message[-1]}

# Stage 3 - Kill a process

# tsk -s 3 -k $key3 & let "pid=$! + 4"

# processes=$(ps -u root)
# processes=($processes)
# pid=${processes[-4]}

# pid=&(tsk -s 3 -k $key3)


tsk -s 3 -k $key3 2> fl.txt
message=$(cat fl.txt)
message=${message#*PID=}
pid=${message%", "*}
sleep 1
while true
    do
    echo "wait"
    kill -SIGUSR1 $pid
    kill -SIGUSR2 $pid
    kill -SIGINT $pid
    sudo ln -s  /var/log/challenge/done.key ~/done.key
    cat /var/log/challenge/done.key
    if [[ $? == 0 ]]; then
        break
    fi
    done
sudo ln -s  /var/log/challenge/done.key ~/done.key    
tsk -s 3 -k $key3 -c
message=$(tsk -s 3 -k $key3 -c 2>&1)
message=($message)
key4=${message[-1]}

# Stage 4 - curl

tsk -s 4 -k $key4
message=$(tsk -s 4 -k $key4 2>&1)
message=($message)
request_id=${message[-9]}

curl -H "X-Request-ID: $request_id" -i localhost:9182/task1
answer=$(curl -H "X-Request-ID: $request_id" -i localhost:9182/task1)
answer=($answer)
credentials=${answer[7]}

curl -X POST -F "credentials=${credentials::-1}" -i localhost:9182/task2
answer=$(curl -X POST -F "credentials=${credentials::-1}" -i localhost:9182/task2)
answer=($answer)
let "counter = 0"
while [[ ${answer[-2]} == 0* ]]; do
    let "counter++"
    location=${answer[9]};
    if [[ ${answer[1]} == 3* ]]; then
        location=${answer[5]};
    fi;
    location=${location::-1};
    # echo $location
    if [[ $location == /* ]]; then
        location=${location:1};
        # echo $location;
    fi;
    if [[ $location == task2* ]]; then
        # echo here
        answer=$(curl -X POST -i localhost:9182/$location);
    else
        answer=$(curl -X POST -i localhost:9182/task2/$location)
    fi
    # echo "$answer"
    answer=($answer);
    echo "redirecting to $location...'"
done;

curl -X DELETE -i localhost:9182/task3/$counter
tsk -s 4 -k $key4 -c
message=$(tsk -s 4 -k $key4 -c 2>&1)
message=($message)
key5=${message[-1]}

# Save keys in keys.txt

keys=($key1 $key2 $key3 $key4 $key5)
for key in ${keys[*]}; do
    echo $key >> keys.txt;
    done;
