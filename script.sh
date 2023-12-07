#! /bin/bash
path_scr=$(dirname "$0")
if ! command -v flock
then
    apt-get install -y util-linux
fi
trap "rm -rf $path_scr/.myscript.exclusivelock" QUIT INT TERM EXIT
( 
  flock -x -w 10 200
  if [ "$?" != "0" ]; then echo Cannot lock!; exit 1; fi
  echo $$>>$path_scr/.myscript.exclusivelock 
  
    log_file="$path_scr/access1.log"
    file=$(<$log_file)
    if [ -f "$path_scr/last_str" ]
    then
        last_time=$(<$path_scr/last_str)
        file=$(echo "$file" | grep -A $(echo "$file" | wc -l) "$last_time" | sed 1d)
    fi
    #| awk '{print $2 " " $1}'
    if [ -s $log_file ]
    then
        count_ips=$(echo "$file" | awk '{print $1}' | sort | uniq -c | awk '{print $2 " " $1}' | sort -rn -k 2 )
        count_requests=$(echo "$file" | awk -F'"' '{print $2}' | grep -v '^\\x' | awk '{print $2}'| sort | uniq -c | awk '{print $2 " " $1}' | sort -rn -k 2 )
        count_status=$(echo "$file" | awk -F'"' '{print $3}' | grep -v '^\\x' | awk '{print $1}'| sort | uniq -c | awk '{print $2 " " $1}' | sort -rn -k 2 )
        errors=$(echo "$file" | awk -F'"' '{print $3}' | grep -v '^\\x' | awk '{print $1}'| sort | uniq | awk '{ if ($1>299) print $1}')
        #last_time_str=$(echo "$file" | sed -e 's/.*\[//' -e 's/].*//' | tail -n 1 | read d; date -d "$d" +'%s')
        first_str=$(echo "$file" | sed -e 's/.*\[//' -e 's/].*//' | head -n 1 )
        pre_last_str=$(echo "$file" | sed -e 's/.*\[//' -e 's/].*//' | tail -n 1 )
        if [[ -z $pre_last_str ]]
        then
            last_time_str=$last_time
        else
            last_time_str=$pre_last_str
        fi
        
        
        echo "Время начала работы скрипта" > $path_scr/message
        echo "$(date '+%d/%b/%Y:%H:%M:%S +%4N')">>$path_scr/message

        echo "ip с количеством запросов" >> $path_scr/message
        echo "$count_ips">>$path_scr/message
        echo "URL с количеством запросов">>$path_scr/message
        echo "$count_requests">>$path_scr/message
        echo "найденые ошибки">>$path_scr/message
        echo "$errors">>$path_scr/message
        echo "статусы с количеством">> $path_scr/message
        echo "$count_status">>$path_scr/message

        echo "Время окончания работы скрипта" >> $path_scr/message
        echo "$(date '+%d/%b/%Y:%H:%M:%S +%4N')">>$path_scr/message

    fi
    if [[ ! -z $pre_last_str ]]
    then
        ms=$(cat $path_scr/message)
        echo "$ms" | mail -s 'log parsing' a@altemans.ru
        if [ $? -eq 0]
        then
            last_time_str=$first_str
        fi
    fi
    echo $last_time_str > $path_scr/last_str

) 200>$path_scr/.myscript.exclusivelock   

FLOCKEXIT=$? 

exit $FLOCKEXIT  
