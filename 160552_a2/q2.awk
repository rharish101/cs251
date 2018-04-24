#!/usr/bin/awk -f
function throughput(data, A, B)
{
    split(data[A][B]["start_time"], time_arr, ":")
    split(time_arr[3], temp, ".")
    start_time = time_arr[1] * 3600 + time_arr[2] * 60 + temp[1]
    start_time_micro = temp[2]

    split(data[A][B]["end_time"], time_arr, ":")
    split(time_arr[3], temp, ".")
    end_time = time_arr[1] * 3600 + time_arr[2] * 60 + temp[1]
    end_time_micro = temp[2]

    time_diff = end_time - start_time + 0.000001 * (end_time_micro - start_time_micro)
    xput = (data[A][B]["bytes"] - data[A][B]["retrans"]) / time_diff
    return xput
}

function printer(data, A, B)
{
    printf "#packets=" data[A][B]["packets"] ", "
    printf "#datapackets=" data[A][B]["data_packets"] ", "
    printf "#bytes=" data[A][B]["bytes"] ", "
    printf "#retrans=" data[A][B]["retrans"] " "
    printf "xput=%d bytes/sec\n", throughput(data, A, B)
}

# Main
{
    sender = $3
    split($5, receiver_split, ":")
    receiver = receiver_split[1]
    if (data[sender][receiver]["packets"])
    {
        data[sender][receiver]["packets"]++
        if ($NF != 0)
        {
            data[sender][receiver]["data_packets"]++

            seq = $9
            split(seq, seq_split_1, ",")
            split(seq_split_1[1], seq_split_2, ":")
            seq_split_2[1] += 1
            retrans_flag = 0
            for (i in data[sender][receiver]["seq"])
            {
                i_seq[1] = data[sender][receiver]["seq"][i][1]
                i_seq[2] = data[sender][receiver]["seq"][i][2]
                if (seq_split_2[1] >= i_seq[1] && seq_split_2[1] <= i_seq[2])
                {
                    if (seq_split_2[2] >= i_seq[1] && seq_split_2[2] <= i_seq[2])
                    {
                        retrans_flag = 1
                        data[sender][receiver]["retrans"] += seq_split_2[2] - seq_split_2[1] + 1
                        break
                    }
                    else
                    {
                        data[sender][receiver]["retrans"] += i_seq[2] - seq_split_2[1] + 1
                        seq_split_2[1] = i_seq[2] + 1
                    }
                }
                else if (seq_split_2[2] >= i_seq[1] && seq_split_2[2] <= i_seq[2])
                {
                    if (seq_split_2[1] >= i_seq[1] && seq_split_2[1] <= i_seq[2])
                    {
                        retrans_flag = 1
                        data[sender][receiver]["retrans"] += seq_split_2[2] - seq_split_2[1] + 1
                        break
                    }
                    else
                    {
                        data[sender][receiver]["retrans"] += seq_split_2[2] - i_seq[1] + 1
                        seq_split_2[2] = i_seq[1] - 1
                    }
                }
            }
            if (retrans_flag == 0 && seq_split_2[1] && seq_split_2[2])
            {
                len = length(data[sender][receiver]["seq"]) + 1
                data[sender][receiver]["seq"][len][1] = int(seq_split_2[1])
                data[sender][receiver]["seq"][len][2] = int(seq_split_2[2])
            }
        }
        data[sender][receiver]["bytes"] += $NF
        data[sender][receiver]["end_time"] = $1
    }
    else
    {
        if (!connections[receiver][sender])
        {
            connections[sender][receiver] = 1
            delete connections[receiver][sender]
        }
        data[sender][receiver]["packets"] = 1
        if ($NF != 0)
        {
            data[sender][receiver]["data_packets"] = 1
            seq = $9
            split(seq, seq_split_1, ",")
            split(seq_split_1[1], seq_split_2, ":")
            data[sender][receiver]["seq"][1][1] = int(seq_split_2[1] + 1)
            data[sender][receiver]["seq"][1][2] = int(seq_split_2[2])
        }
        else
        {
            data[sender][receiver]["data_packets"] = 0
            data[sender][receiver]["seq"][1][1] = 0
            data[sender][receiver]["seq"][1][2] = 0
        }
        data[sender][receiver]["bytes"] = $NF
        data[sender][receiver]["start_time"] = $1
        data[sender][receiver]["retrans"] = 0
    }
}

END {
    start = 1
    for (A in connections)
        for (B in connections[A])
        {
            if (start == 1)
                start = 0
            else
                print ""
            split(A, A_arr, ".")
            A_ip = A_arr[1] "." A_arr[2] "." A_arr[3] "." A_arr[4]
            split(B, B_arr, ".")
            B_ip = B_arr[1] "." B_arr[2] "." B_arr[3] "." B_arr[4]
            printf "Connection (A=" A_ip ":" A_arr[5] " B=" B_ip ":" B_arr[5] ")\nA-->B "
            printer(data, A, B)
            printf "B-->A "
            printer(data, B, A)
        }
}
