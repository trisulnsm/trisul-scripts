
import pandas as pd
import paramiko
import os
import mysql.connector
from datetime import datetime
from apscheduler.schedulers.blocking import BlockingScheduler

def fetch_and_convert_radacct():
    # Database connection
    db = mysql.connector.connect(
        host="your_db_host",
        user="your_db_user",
        password="your_db_password",
        database="your_db_name"
    )

    # Fetch data from the radacct table
    query = "SELECT * FROM radacct"
    radacct_df = pd.read_sql(query, db)

    # Convert to CSV
    csv_file = f"radacct_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    radacct_df.to_csv(csv_file, index=False)

    db.close()

    return csv_file

def sftp_transfer(csv_file):
    # SFTP server details
    sftp_host = "your_sftp_server"
    sftp_port = 22
    sftp_username = "your_sftp_user"
    sftp_password = "your_sftp_password"
    remote_path = "/opt/ipdr/cdrlogs/" + os.path.basename(csv_file)

    # SFTP connection
    transport = paramiko.Transport((sftp_host, sftp_port))
    transport.connect(username=sftp_username, password=sftp_password)
    sftp = paramiko.SFTPClient.from_transport(transport)

    # File transfer
    sftp.put(csv_file, remote_path)

    # Close SFTP connection
    sftp.close()
    transport.close()

    # Remove local CSV file if desired
    os.remove(csv_file)

def job():
    csv_file = fetch_and_convert_radacct()
    sftp_transfer(csv_file)

# Schedule the job to run daily at a specific time (e.g., 2:00 AM)
scheduler = BlockingScheduler()
scheduler.add_job(job, 'cron', hour=2, minute=0)
scheduler.start()

