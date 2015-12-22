#!/bin/sh

#  LPD_Printer_Queue_via_CocoaDialog_List
#  Copyright (c) Joel Reid 2015
#  Distributed under the MIT License (terms at http://opensource.org/licenses/MIT)
#  Sadly unsure of original author
#  adapted from a script snippet posted unattributed. possibly adapted from:
#  https://github.com/glarizza/cart-examples/blob/master/Printer_Installation/preflight

#  Usage:
# Straightforward enough. Just make sure to install the required drivers first
# if you're not using generic.

# Config _________________________________________________
# Variables. Edit these.
printername=""
location=""
gui_display_name=""
address=""
driver_ppd=""
# Populate these options if you want to set specific options for the printer. E.g. duplexing installed, etc.
option_1=""
option_2=""
option_3=""
### Printer Install ###
# In case we are making changes to a printer we need to remove an existing queue if it exists.
/usr/bin/lpstat -p $printername
if [ $? -eq 0 ]; then
        /usr/sbin/lpadmin -x $printername
fi
# Now we can install the printer.
/usr/sbin/lpadmin \
        -p "$printername" \
        -L "$location" \
        -D "$gui_display_name" \
        -v "$address" \
        -P "$driver_ppd" \
        -o "$option_1" \
        -o "$option_2" \
        -o "$option_3" \
        -o printer-is-shared=false \
        -E
# Enable and start the printers on the system (after adding the printer initially it is paused).
/usr/sbin/cupsenable $(lpstat -p | grep -w "printer" | awk '{print$2}')
# Create an uninstall script for the printer.
uninstall_script="/private/etc/cups/printers_deployment/uninstalls/$printername.sh"
mkdir -p /private/etc/cups/printers_deployment/uninstalls
echo "#!/bin/sh" > "$uninstall_script"
echo "/usr/sbin/lpadmin -x $printername" >> "$uninstall_script"
echo "/usr/bin/srm /private/etc/cups/printers_deployment/uninstalls/$printername.sh" >> "$uninstall_script"
# Permission the directories properly.
chown -R root:_lp /private/etc/cups/printers_deployment
chmod -R 700 /private/etc/cups/printers_deployment

exit 0
