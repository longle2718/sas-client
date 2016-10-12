Piping data from Illiad to the GDP
==================
# GDP router and/or log daemon configuration
    echo "swarm.gdp.routers=gdp-03.eecs.berkeley.edu; gdp-02.eecs.berkeley.edu; gdp-01.eecs.berkeley.edu" > /etc/ep_adm_params/gdp

# Install python dependencies
    pip install requests
    pip install pika
# Create a log without signature key
	gcl-create -k none <my.log.name>
# Run the main module periodically (every 15 mins) using cron
	crontab -e
	*/15 * * * * /usr/bin/python ~/sas-clientLib/demo/gdpConn/illiad2gdp.py
