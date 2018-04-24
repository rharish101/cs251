#!/usr/bin/awk -f
BEGIN {
    uname_col=0
    pid_col=0
    ppid_col=0
    lwp_col=0
    sz_col=0
    rss_col=0
    start_col=0
    time_col=0

    prev_pid=0

    dict["blank"]["proc"]=0
    dict["blank"]["threads"]=0
    dict["blank"]["cpu"]=0
    dict["blank"]["memory"]=0
}

# Main
{
    if (NR==1)
    {
        for (i=1;i<=NF;i++)
        {
            if ($i == "USER")
                uname_col=i
            else if ($i == "PID")
                pid_col=i
            else if ($i == "PPID")
                ppid_col=i
            else if ($i == "LWP")
                lwp_col=i
            else if ($i == "SZ")
                sz_col=i
            else if ($i == "RSS")
                rss_col=i
            else if ($i == "START")
                start_col=i
            else if ($i == "TIME")
                time_col=i
        }
    }
    else
    {
        user=$uname_col
        if (dict[user]["proc"])
        {
            dict[user]["threads"]++
            if ($pid_col != prev_pid)
            {
                dict[user]["proc"]++
                dict[user]["memory"] += $rss_col
                dict[user]["pages"] += $sz_col
            }
            prev_pid = $pid_col
            split($time_col, time_arr, ":")
            dict[user]["cpu"] += time_arr[1]*3600 + time_arr[2]*60 + time_arr[3]
        }
        else
        {
            dict[user]["proc"]=1
            dict[user]["threads"]=1
            split($time_col, time_arr, ":")
            dict[user]["cpu"] = time_arr[1]*3600 + time_arr[2]*60 + time_arr[3]
            dict[user]["memory"]=$rss_col
            dict[user]["pages"]=$sz_col
            prev_pid=$pid_col
        }
    }
}

END {
    print "No. of users: " (length(dict) - 1)
    for (user in dict)
    {
        if (user == "blank")
            continue

        print "For user: " user
        print "\tNo. of processes: " dict[user]["proc"]
        print "\tNo. of threads: " dict[user]["threads"]
        cpu_t=dict[user]["cpu"]
        print "\tTotal CPU time: " int(cpu_t/3600) ":" int((cpu_t%3600)/60) ":" cpu_t%60
        print "\tTotal memory consumption: " dict[user]["memory"] " KiB"
        print "\tTotal pages: " dict[user]["pages"] " pages"
    }
}
