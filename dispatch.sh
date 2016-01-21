while true
do
    killall bash
    ./dispatch_all.sh &
    sleep 60
done

