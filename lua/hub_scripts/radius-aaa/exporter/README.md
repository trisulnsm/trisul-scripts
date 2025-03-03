# FreeRADIUS Sample exporter

The session data in FreeRADIUS is stored in the MySQL table called radacct. 


We need to export the full or part of this table. This sample python script exports the full table.


> UPDATE:  A full dump can result in a giant database dump.  Hence the script only dumps active sessions in the last ONE hour
> ISP can customize the script to dump every 3 Hours, 6 Hours, 24 Hours etc


```python

one_hour_ago = datetime.now() - timedelta(hours=1)

    # Fetch data from the radacct table
	query = f"""
SELECT * FROM radacct
WHERE acctstarttime >= '{one_hour_ago.strftime('%Y-%m-%d %H:%M:%S')}'
OR acctstoptime >= '{one_hour_ago.strftime('%Y-%m-%d %H:%M:%S')}'
OR accttime >= '{one_hour_ago.strftime('%Y-%m-%d %H:%M:%S')}'
""" 

```



## export-radacct.py 

This python script exports the entire radacct table to a CSV file and SFTP to Trisul IPDR server 

Uses the pandas library to convert the radacct table from a FreeRADIUS database to a CSV file and paramiko for SFTP transfer to a different server.ddkk

```bash

pip install pandas paramiko

```


## What is in the radacct table 

The radacct table contains 

| Field Name               | Data Type        | Description                                                                 |
|--------------------------|------------------|-----------------------------------------------------------------------------|
| `RadAcctId`              | BIGINT           | A unique identifier for each accounting record.                             |
| `AcctSessionId`          | VARCHAR(64)      | A unique identifier for the session.                                        |
| `AcctUniqueId`           | VARCHAR(32)      | Another unique identifier for the accounting record.                        |
| `UserName`               | VARCHAR(64)      | The username of the user for the session.                                   |
| `Realm`                  | VARCHAR(64)      | The realm associated with the user.                                         |
| `NASIPAddress`           | VARCHAR(15)      | The IP address of the NAS (Network Access Server) that handled the session. |
| `NASPortId`              | VARCHAR(15)      | The port identifier on the NAS.                                             |
| `NASPortType`            | VARCHAR(32)      | The type of port used on the NAS.                                           |
| `AcctStartTime`          | DATETIME         | The time when the session started.                                          |
| `AcctStopTime`           | DATETIME         | The time when the session ended (if applicable).                            |
| `AcctSessionTime`        | INT              | The duration of the session in seconds.                                     |
| `AcctAuthentic`          | VARCHAR(32)      | The type of authentication used.                                            |
| `ConnectInfo_start`      | VARCHAR(50)      | Connection information at the start of the session.                         |
| `ConnectInfo_stop`       | VARCHAR(50)      | Connection information at the end of the session.                           |
| `AcctInputOctets`        | BIGINT           | The number of octets (bytes) received by the user during the session.       |
| `AcctOutputOctets`       | BIGINT           | The number of octets (bytes) sent by the user during the session.           |
| `CalledStationId`        | VARCHAR(50)      | The identifier of the called station (often used to indicate the NAS identifier). |
| `CallingStationId`       | VARCHAR(50)      | The identifier of the calling station (often used to indicate the user's device). |
| `AcctTerminateCause`     | VARCHAR(32)      | The reason why the session was terminated.                                  |
| `FramedIPAddress`        | VARCHAR(15)      | The IP address assigned to the user's device during the session.            |
| `AcctStartDelay`         | INT              | Delay in starting the accounting record.                                    |
| `AcctStopDelay`          | INT              | Delay in stopping the accounting record.                                    |
| `XAscendSessionsSvrKey`  | VARCHAR(10)      | Vendor-specific attribute.                                                  |



