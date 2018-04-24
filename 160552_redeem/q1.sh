#!/usr/bin/env sh
xml=`cat $1`

# Flags and status names
inside_tag=false
negation=false
tag_name=""
command=""
name=""
size=""

for i in `seq 1 ${#xml}`
do
    char="${xml:$((i-1)):1}"

    if [[ $char == "<" ]]; then
        inside_tag=true

    elif [[ $inside_tag == true ]]; then
        if [[ $char == "/" ]] && [[ $tag_name == "" ]]; then
            negation=true # Ending tag
        elif [[ $char == ">" ]]; then
            inside_tag=false

            case $tag_name in
                "dir")
                    if [[ $negation == false ]]; then
                        command="dir"
                    else
                        cd ..
                    fi
                    ;;
                "file")
                    if [[ $negation == false ]]; then
                        command="file"
                    else
                        name=`echo $name | sed -e 's/^[ \t]*//;s/[ \t]*$//'`
                        size=`echo $size | sed -e 's/^[ \t]*//;s/[ \t]*$//'`
                        dd if=/dev/zero of=$name bs=$size count=1 &>/dev/null
                        command=""
                        name=""
                        size=""
                    fi
                    ;;
                "name")
                    case $command in
                        "dir")
                            command="dir_name"
                            ;;
                        "file")
                            command="file_name"
                            ;;
                        "dir_name")
                            mkdir $name
                            cd $name
                            command=""
                            name=""
                            ;;
                        "file_name")
                            command="file"
                            ;;
                    esac
                    ;;
                "size")
                    command="size"
                    ;;
            esac

            tag_name=""
            negation=false
        else
            tag_name="${tag_name}${char}"
        fi

    # Storing name
    elif [[ $command == "dir_name" ]] || [[ $command == "file_name" ]]; then
        name="${name}${char}"

    # Storing size
    elif [[ $command == "size" ]]; then
        size="${size}${char}"
    fi
done
