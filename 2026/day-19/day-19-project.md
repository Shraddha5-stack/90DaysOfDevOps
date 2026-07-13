## Task 3: Crontab

### Check Current Cron Jobs

```bash
crontab -l
```

### Output

```text
no crontab for shraddha
```

**Observation:**
- There are currently no scheduled cron jobs for my user.

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

**Run log_rotate.sh every day at 2:00 AM**

```cron
0 2 * * * /home/shraddha/90DaysOfDevOps/2026/day-19/log_rotate.sh /home/shraddha/myapp/logs
```

**Run backup.sh every Sunday at 3:00 AM**

```cron
0 3 * * 0 /home/shraddha/90DaysOfDevOps/2026/day-19/backup.sh /home/shraddha/Documents /home/shraddha/backups
```

**Run health_check.sh every 5 minutes**

```cron
*/5 * * * * /home/shraddha/90DaysOfDevOps/2026/day-19/health_check.sh
```




# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

## Task 1: Log Rotation Script

### Script

![Log Rotate Script](screenshots/log-rotate-script.png)

### Output

![Log Rotate Output](screenshots/log-rotate-output.png)

---

## Task 2: Server Backup Script

### Script

![Backup Script](screenshots/backup-script.png)

### Output

![Backup Output](screenshots/backup-output.png)

---

## Task 3: Crontab

### Current Crontab

![Crontab](screenshots/crontab.png)

### Cron Entries

![Cron Entries](screenshots/cron-entries.png)

---

## Task 4: Scheduled Maintenance Script

### Script

![Maintenance Script](screenshots/maintenance-script.png)

### Output

![Maintenance Log](screenshots/maintenance-log.png)

---

## Project Structure

![Project Tree](screenshots/project-tree.png)
