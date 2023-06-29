#Check the %of disk used and send alert if it goes over a provided max
#arg 1 = disk to check
#arg 2 = %max... if over then send alert
#arg 3 = email address for the alert

        #get the %used
        pcent_used=$(df --output=pcent $1  | egrep -v Use% | tr '%' ' ')

        echo "%used = " $pcent_used

        if [ $pcent_used -gt $2 ]; then
                echo "over the minimumn, send email"
                echo "The disk usage in server" $(hostname) $(hostname -I) "is over the maximum (" $pcent_used "% > " $2 "%)" | mail -s "alert (low disk space) from sari sari server " $3
        else
                echo "no problem. do not send email"
        fi
