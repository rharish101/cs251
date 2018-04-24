#!/usr/bin/env sh
folder=$1
len=${#folder}
if [[ "${folder:$((len-1)):1}" != "/" ]]
then
    folder="${folder}/"
fi

comment_count=0
string_count=0
info_folder ()
{
    local current=$1
    local earlier=${2:-""}
    local local_com_count=0
    local local_str_count=0

    IFS=$'\n'
    for content in $(ls -p "${earlier}${current}")
    do
        if [[ $content =~ /$ ]]
        then
            info_folder ${content} "${earlier}${current}"
            local_com_count=$(( $local_com_count + $comment_count ))
            local_str_count=$(( $local_str_count + $string_count ))
        elif [[ "${content:$((${#content}-2)):2}" == ".c" ]]
        then
            awk_output=$(./q1.awk < "${earlier}${current}${content}")
            file_com_count=$(echo $awk_output | awk '{print $1}')
            file_str_count=$(echo $awk_output | awk '{print $2}')
            local_com_count=$(( $local_com_count + $file_com_count ))
            local_str_count=$(( $local_str_count + $file_str_count ))
        fi
    done

    comment_count=$local_com_count
    string_count=$local_str_count
}

info_folder $folder
echo "${comment_count} lines of comments"
echo "${string_count} quoted strings"
