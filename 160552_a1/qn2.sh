#!/usr/bin/env sh
folder=$1
len=${#folder}
if [[ "${folder:$((len-1)):1}" != "/" ]]
then
    folder="${folder}/"
fi

# Function to print indents
echo_indent ()
{
    for i in $(seq 0 $(($1 - 1 )))
    do
        echo -ne "\t"
    done
}

# Function to print directory tree contents with sentence and integer counts
sentence_count=0
int_count=0
info_folder ()
{
    local current=$1
    local len=${#current}
    local indent=${2:-0}
    local earlier=${3:-""}
    local local_sen_count=0
    local local_int_count=0

    IFS=$'\n'
    for content in $(ls -p "${earlier}${current}")
    do
        if [[ $content =~ /$ ]]
        then
            info_folder ${content} $(( $indent + 1 )) "${earlier}${current}"
            local_sen_count=$(( $local_sen_count + $sentence_count ))
            local_int_count=$(( $local_int_count + $int_count ))
        else
            file_sen_count=$(cat "${earlier}${current}${content}" | tr '\n' ' ' | grep -oE "[0-9]+\.[0-9]+\.|[^\.][\.][^0-9]|[^0-9|\.][\.][0-9]$|[^\?]\?|[^\!]\!|[\.\?\!]!" | wc -l)
            file_int_count=$(cat "${earlier}${current}${content}" | tr '\n' ' ' | sed 's/ /  /g; s/?/??/g; s/!/!!/g' | grep -oE "[0-9]+\.[0-9]+\.[0-9]+|(\s|-)[0-9]+(\s|\.[^0-9]|\?|\!)|^[0-9]+(\s|\.[^0-9]|\?|\!)|[\?\!][0-9]+|[^0-9]\.[0-9]+" | wc -l)
            local_sen_count=$(( $local_sen_count + $file_sen_count ))
            local_int_count=$(( $local_int_count + $file_int_count ))
            echo_indent $(( $indent + 1 ))
            echo "(F) ${content}-${file_sen_count}-${file_int_count}"
        fi
    done

    echo_indent $indent
    echo "(D) ${current:0:$(($len-1))}-${local_sen_count}-${local_int_count}"
    sentence_count=$local_sen_count
    int_count=$local_int_count
}

info_folder "$folder"

