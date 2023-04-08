#!/bin/bash

user=<username>
pass=<password>

curl -s -c cookies.txt -X POST https://www.lexaloffle.com/account.php?page=login -d "user=$user&pass=$pass&go=/"

latest_file=$(curl -s -b cookies.txt https://www.lexaloffle.com/games.php?page=archive | sed 's/<br>/\n/g'  | grep -Eo ">pico-.+\amd64.\zip<" | tr -d '<>' | sort -r | head -1)
latest_version=$(echo -n $latest_file | sed 's/_amd64.zip//g')


function should_update() {
    if [ ! -f  "installed.txt" ]
    then
        return 0
    fi

    current_version=$(cat "installed.txt")
    if [ $current_version != $1 ]
    then
        return 0
    fi
    return 1
}

if should_update $latest_version
then
    output_dir="tmp"
    mkdir -p $output_dir
    curl -s -b cookies.txt -X GET https://www.lexaloffle.com/dl/7tiann/$latest_file --output $output_dir/$latest_file
    if [ -d pico-8 ] 
    then
        rm -r pico-8
    fi
    unzip $output_dir/$latest_file
    rm -r $output_dir
    echo -n $latest_version > installed.txt
    echo "updated to version $latest_version"
else
    echo "alread on latest version"
fi

rm cookies.txt


pico-8/pico8 $@

