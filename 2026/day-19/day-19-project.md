# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

## Task 1: Log Rotation Script

### Objective

Create a shell script that:

* Takes a log directory as an argument.
* Compresses `.log` files older than 7 days.
* Deletes `.gz` files older than 30 days.
* Prints the number of compressed and deleted files.
* Exits with an error if the directory does not exist.

### Script

Here is the script **log_rotate.sh**.

### Screenshot

![Log Rotation Script](screenshots/log-rotate-script.png)

### Sample Output

![Log Rotation Output](screenshots/log-rotate-output.png)

### Observation

* The script checks whether the log directory exists.
* Old log files are compressed using `gzip`.
* Old compressed files are removed automatically.
* Displays the number of files compressed and deleted.

---

# Task 2: Server Backup Script

### Objective

Create a backup script that:

* Takes source and destination directories as arguments.
* Creates a timestamped `.tar.gz` archive.
* Verifies the backup.
* Displays archive name and size.
* Removes backups older than 14 days.

### Script

Here is the script **backup.sh**.

### Screenshot

![Backup Script](screenshots/backup-script.png)

### Sample Output

![Backup Output](screenshots/backup-output.png)

### Observation

* Backup archive is created successfully.
* Archive name contains the current date and time.
* Old backups are cleaned up automatically.
* Backup size is displayed after creation.

---

# Task 3: Crontab

## Current Cron Jobs

```bash
crontab -l
```

### Output

```text
no crontab for shraddha
```

### Observation

Currently there are no cron jobs configured for my user.

---

## Cron Syntax

```text
* * * * * command
│ │ │ │ │
│ │ │ │ └── Day of Week (0-7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of Month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

### Cron Entries

#### Run Log Rotation every day at 2:00 AM

```cron
0 2 * * * /home/shraddha/90DaysOfDevOps/2026/day-19/log_rotate.sh /home/shraddha/logs
```

#### Run Backup every Sunday at 3:00 AM

```cron
0 3 * * 0 /home/shraddha/90DaysOfDevOps/2026/day-19/backup.sh /home/shraddha/Documents /home/shraddha/backups
```

#### Run Health Check every 5 minutes

```cron
*/5 * * * * /home/shraddha/90DaysOfDevOps/2026/day-19/health_check.sh
```

### Screenshot

![Crontab](screenshots/crontab.png)

![Cron Entries](screenshots/cron-entries.png)

---

# Task 4: Scheduled Maintenance Script

### Objective

Create a maintenance script that:

* Calls the log rotation script.
* Calls the backup script.
* Stores execution logs in `maintenance.log`.
* Can be scheduled through cron.

### Script

Here is the script **maintenance.sh**.

### Screenshot

![Maintenance Script](screenshots/maintenance-script.png)

### Sample Output

![Maintenance Log](screenshots/maintenance-log.png)

---

# Project Structure

### Directory Layout

![Project Tree](screenshots/project-tree.png)

---

# What I Learned

* Learned how to automate log rotation using `find`, `gzip`, and `mtime`.
* Created compressed backups with `tar` and timestamped filenames.
* Understood cron scheduling syntax and how to automate recurring tasks.
* Combined multiple scripts into a single maintenance workflow.
* Logged maintenance operations with timestamps for easier monitoring and troubleshooting.

