steps to deploy

save this to /home/jrock/mnt/extdrive/fileshare/update_status.sh

make it executable:

bash
Copy
Edit
chmod +x /home/jrock/mnt/extdrive/fileshare/update_status.sh
run on-demand:

bash
Copy
Edit
/home/jrock/mnt/extdrive/fileshare/update_status.sh
schedule hourly (via crontab -e):

ruby
Copy
Edit
0 * * * * /home/jrock/mnt/extdrive/fileshare/update_status.sh
now you’ll have the lighter-blue background again plus total cpu cores and total ram displayed along with the bars and percents.
