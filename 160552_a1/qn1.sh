#!/usr/bin/env sh
num=$1
length=${#num}

# Invalid check
if [[ ! $num =~ ^[0-9]+$ ]]
then
    echo "invalid input"
    exit -1
fi

# Trim the number
for (( i=0; i<$(($length - 1)); i++ ))
do
    if (( ${num:i:1} != 0 ))
    then
        break
    fi
done
length=$(($length - i))
num=${num:i:$length}

answer=""

# Return the units place name
ones_place ()
{
    number=$1
    zero=${2:-false}
    len=${#number}
    if (( $len == 1 ))
    then
        case $number in
            0)
                if [[ $zero == 'true' ]]
                then
                    string="zero"
                else
                    string=""
                fi
                ;;
            1)
                string="one"
                ;;
            2)
                string="two"
                ;;
            3)
                string="three"
                ;;
            4)
                string="four"
                ;;
            5)
                string="five"
                ;;
            6)
                string="six"
                ;;
            7)
                string="seven"
                ;;
            8)
                string="eight"
                ;;
            9)
                string="nine"
                ;;
        esac
        answer="${answer}${string} "
    fi
}

# Return the twos and ones place name
twos_ones_place ()
{
    number=$1
    zero=${2:-true}
    len=${#number}
    if (( $len == 2 ))
    then
        flag=true
        string=""
        case $number in
            11)
                string="eleven "
                ;;
            12)
                string="twelve "
                ;;
            13)
                string="thirteen "
                ;;
            14)
                string="fourteen "
                ;;
            15)
                string="fifteen "
                ;;
            16)
                string="sixteen "
                ;;
            17)
                string="seventeen "
                ;;
            18)
                string="eightteen "
                ;;
            19)
                string="nineteen "
                ;;
            *)
                flag=false
                ;;
        esac
        answer="${answer}${string}"
        if [[ $flag == false ]]
        then
            case ${number:0:1} in
                1)
                    string="ten "
                    ;;
                2)
                    string="twenty "
                    ;;
                3)
                    string="thirty "
                    ;;
                4)
                    string="forty "
                    ;;
                5)
                    string="fifty "
                    ;;
                6)
                    string="sixty "
                    ;;
                7)
                    string="seventy "
                    ;;
                8)
                    string="eighty "
                    ;;
                9)
                    string="ninety "
                    ;;
            esac
            answer="${answer}${string}"
            ones_place ${number:1:1}
        fi
    elif (( $len == 1))
    then
        ones_place $number $zero
    fi
}

# Return the hundreds place name
hundred_place ()
{
    number=$1
    len=${#number}
    if (( $len == 1 )) && (( $number != 0 ))
    then
        ones_place $number
        answer="${answer}hundred "
    fi
}

# Return the thousands place name
thousand_place ()
{
    number=$1
    len=${#number}
    if (( $len == 2 )) && [[ ${number:0:1} == '0' ]] && [[ ${number:1:1} == '0' ]]
    then
        return
    elif (( $len == 1 )) && [[ ${number:0:1} == '0' ]]
    then
        return
    elif (( $len <= 2 ))
    then
        twos_ones_place $number false
        answer="${answer}thousand "
    fi
}

# Return the thousands and before place name
thousands_and_before_places ()
{
    integer=$1
    zero=${2:-true}
    digits=${#integer}
    if (( $digits == 5 ))
    then
        thousand_place ${integer:0:2}
        hundred_place ${integer:2:1}
        twos_ones_place ${integer:3:2} false
    elif (( $digits == 4 ))
    then
        thousand_place ${integer:0:1}
        hundred_place ${integer:1:1}
        twos_ones_place ${integer:2:2} false
    elif (( $digits == 3 ))
    then
        hundred_place ${integer:0:1}
        twos_ones_place ${integer:1:2} false
    elif (( $digits < 3 ))
    then
        twos_ones_place ${integer:0:2} $zero
    fi
}

# Return the lakhs place name
lakhs_place ()
{
    number=$1
    len=${#number}
    if (( $len == 2 )) && [[ ${number:0:1} == '0' ]] && [[ ${number:1:1} == '0' ]]
    then
        return
    elif (( $len == 1 )) && [[ ${number:0:1} == '0' ]]
    then
        return
    elif (( $len <= 2 ))
    then
        twos_ones_place $number false
        answer="${answer}lakh "
    fi
}

# Length check
if (( $length > 11 ))
then
    echo "invalid input"
    exit -1
fi

# Crores
if (( $length > 7 ))
then
    thousands_and_before_places ${num:0:$(($length-7))} false
    num=${num:$(($length-7)):7}
    length=7
    answer="${answer}crore "
fi

# Lakhs
if (( $length == 7 ))
then
    lakhs_place ${num:0:2}
    length=$(( $length - 2))
    num=${num:2:$length}
elif (( $length == 6 ))
then
    lakhs_place ${num:0:1}
    length=$(( $length - 1))
    num=${num:1:$length}
fi

# Thousands
if (( $length < 6 ))
then
    thousands_and_before_places $num
fi

echo $answer
