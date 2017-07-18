#!/bin/bash

# At this point I feel it is unwise to continue using bash for this
# I would like to add command switches for color and icons, this CAN be done 
# however arg parsing in bash is shit. Also a python option would be better
# for cross platform, we can also hook into the IPC channel of the main script.


KPATH="/pentest/keep_notes/knoteDB"

simplepage=$(cat <<__EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<body>DATA_REPLACE</body>
</html>
__EOF
)

folderdata=$(cat <<__EOF
<?xml version="1.0" encoding="UTF-8"?>
<node>
<version>6</version>
<dict>
  <key>title_fgcolor</key><string>#000000</string>
  <key>title_bgcolor</key><string>#ffffff</string>
  <key>title</key><string>NAME_REPLACE</string>
  <key>nodeid</key><string>NODE_ID_REPLACE</string>
  <key>modified_time</key><integer>1500329607</integer>
  <key>version</key><integer>6</integer>
  <key>content_type</key><string>application/x-notebook-dir</string>
  <key>created_time</key><integer>1500329607</integer>
  <key>info_sort_dir</key><integer>1</integer>
  <key>order</key><integer>0</integer>
  <key>info_sort</key><string>order</string>
</dict>
</node>
__EOF
)

pagedata=$(cat <<__EOF
<?xml version="1.0" encoding="UTF-8"?>
<node>
<version>6</version>
<dict>
  <key>title_fgcolor</key><string>#000000</string>
  <key>title_bgcolor</key><string>#ffffff</string>
  <key>icon</key><string>note.png</string>
  <key>title</key><string>NAME_REPLACE</string>
  <key>nodeid</key><string>NODE_ID_REPLACE</string>
  <key>modified_time</key><integer>1500329852</integer>
  <key>version</key><integer>6</integer>
  <key>content_type</key><string>text/xhtml+xml</string>
  <key>created_time</key><integer>1500329852</integer>
  <key>order</key><integer>0</integer>
</dict>
</node>
__EOF
)


make_page ()
{
    name=$1
    new_uuid=$2
    node1=$(echo "$pagedata" | sed "s/NODE_ID_REPLACE/$new_uuid/g")
    node2=$(echo "$node1" | sed "s/NAME_REPLACE/$name/g")
    echo "$node2"
}

make_folder ()
{
    name=$1
    new_uuid=$2
    node1=$(echo "$folderdata" | sed "s/NODE_ID_REPLACE/$new_uuid/g")
    node2=$(echo "$node1" | sed "s/NAME_REPLACE/$name/g")
    echo "$node2"
}


if [ "$#" -lt 2 ]; then
    echo "# keepnote MUST be close or you can corrupt you DB"
    echo "$0 -f <folder>"
    echo "$0 -p <page> <data>"
    exit
fi

keepnote_running=$(ps aufx | grep keepnote | grep -v "grep keepnote" | awk '{print $2}')
if [ -z $keepnote_running ] ; 
then
    echo "keepnote not running..."
else
    echo "Killing keepnote..."
    kill -9 $keepnote_running
fi


if [ "$1" == "-f" ]; then
    sid=$(uuidgen)
    npath=$2
    nfile=$(echo "$npath" | grep -o '[^/]*$')
    ret=$(make_folder $nfile $sid)
    NEW_FILE="$KPATH$npath"
    mkdir $NEW_FILE
    echo "$ret" > $NEW_FILE/node.xml
    echo "$nfile    nbk:///$sid"
elif [ "$1" == "-p" ]; then
    sid=$(uuidgen)
    npath=$2
    nfile=$(echo "$npath" | grep -o '[^/]*$')
    ndata=$3
    ret=$(make_page $nfile $sid)
    NEW_FILE="$KPATH$npath"
    mkdir $NEW_FILE
    echo "$ret" > $NEW_FILE/node.xml
    htmlpage=$(echo "$simplepage" | sed "s/DATA_REPLACE/$ndata/g")
    echo "$htmlpage" > $NEW_FILE/page.html
    echo "$nfile    nbk:///$sid"
fi
