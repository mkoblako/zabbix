
COMMAND="sudo -H -u zimbra /opt/zimbra/bin/zmcontrol"

VERS=$($COMMAND -v)
if [ $? -eq 0 ] ; then
   echo $VERS
   exit 0;
fi
