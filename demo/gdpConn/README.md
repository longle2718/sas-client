Piping data from Illiad to the GDP
==================

# Create a log
	logCreate <my.log.name>
# Run the main module periodically (every 15 mins) using cron
	crontab -e
	*/15 * * * * /usr/bin/python ~/sas-clientLib/demo/gdpConn/main.py
