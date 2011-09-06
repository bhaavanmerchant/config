#!/bin/bash
FILE=$(banshee --query-uri | cut -c13-)
EXT=${FILE##*.}
TTHSUM=$(tthsum "${FILE}"|cut -b1-39)
SIZE=$(stat -c%s "$FILE")
#NAME=$(basename "$(mpc -f "[[%artist% - ]&[%title%]]|[%file%]"|head -1)"|tr ' ' '+')
#NAME1=${NAME%.mp3}
#DETAILS=$(mpc -f [%length%])
STATE=$(banshee --query-current-state)
echo /me  is now $STATE "magnet:?xt=urn:tree:tiger:${TTHSUM}&xl=$SIZE&dn=$NAME1.$EXT" $DETAILS"
