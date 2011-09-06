#!/bin/bash
FILE="/media/Data/Mera Music/$(mpc -f %file% | head -1)"
EXT=${FILE##*.}
TTHSUM=$(tthsum "${FILE}"|cut -b1-39)
SIZE=$(stat -c%s "$FILE")
NAME=$(basename "$(mpc -f "[[%artist% - ]&[%title%]]|[%file%]"|head -1)"|tr ' ' '+')
NAME1=${NAME%.mp3}
DETAILS=$(mpc -f [%length%])
stringZ=`ifconfig`
z=`echo ${stringZ:78:9}`
z=ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'
m=":8000/"
j="http://"
#echo "being broadcasted on :"
#echo $j$z$m
echo /me  is now playing "magnet:?xt=urn:tree:tiger:${TTHSUM}&xl=$SIZE&dn=$NAME1.$EXT" $DETAILS also being broadcated on $j$z$m
