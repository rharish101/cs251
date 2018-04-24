#!/usr/bin/awk -f
BEGIN {
    FS=""
    is_comment_test = 0
    is_comment = 0
    is_multi_comment = 0
    is_string = 0
    num_comments = 0
    num_strings = 0
}
{
    line_is_comment = 0
    if (is_multi_comment == 1)
        num_comments++
    for(i=1;i<=length($0);i++)
    {
        if ($i == "/" && is_string == 0 && is_comment == 0 && is_multi_comment == 0 && is_comment_test == 0)
            is_comment_test = 1
        else if ($i == "/" && is_string == 0 && is_comment == 0 && is_multi_comment == 0 && is_comment_test == 1)
        {
            is_comment = 1
            is_comment_test = 0
            if (line_is_comment == 0)
            {
                num_comments++
                line_is_comment = 1
            }
        }
        else if ($i == "*" && is_string == 0 && is_comment == 0 && is_multi_comment == 0 && is_comment_test == 1)
        {
            is_multi_comment = 1
            is_comment_test = 0
            if (line_is_comment == 0)
            {
                num_comments++
                line_is_comment = 1
            }
        }
        else if ($i == "*" && is_string == 0 && is_comment == 0 && is_multi_comment == 1 && is_comment_test == 0)
            is_comment_test = 2
        else if ($i == "/" && is_string == 0 && is_comment == 0 && is_multi_comment == 1 && is_comment_test == 2)
        {
            is_multi_comment = 0
            is_comment_test = 0
        }
        else if ($i == "\"" && is_string == 0 && is_comment == 0 && is_multi_comment == 0 && is_comment_test == 0)
        {
            is_string = 1
            num_strings++
        }
        else if ($i == "\"" && is_string == 1 && is_comment == 0 && is_multi_comment == 0 && is_comment_test == 0)
            is_string = 0
        else
            is_comment_test = 0
    }
    is_comment = 0
    is_comment_test = 0
}
END {
    print num_comments " " num_strings
}
