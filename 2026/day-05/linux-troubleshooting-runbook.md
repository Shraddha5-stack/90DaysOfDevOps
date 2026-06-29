# Linux Service Practice – SSH Service Runbook

## Objective

The objective of this practice was to inspect the SSH service, verify its health, review related logs, and understand the basic troubleshooting steps that a DevOps Engineer can follow when diagnosing Linux service issues.

---

# 1. System Information

### Command

```bash
uname -a
```

**Purpose:** Displays the Linux kernel version, system architecture, and hostname.

**Observation:** Verified that the system is running Linux successfully.

---

### Command

```bash
cat /etc/os-release
```

**Purpose:** Displays Linux distribution information.

**Observation:** Confirmed the Ubuntu version and release details.

---

# 2. Process Verification

### Command

```bash
ps -ef | grep ssh
```

**Purpose:** Checks whether SSH-related processes are running.

**Observation:** Verified that the SSH daemon process is active.

---

### Command

```bash
top
```

**Purpose:** Monitors CPU, memory usage, and running processes in real time.

**Observation:** System resources were healthy with no unusually high CPU or memory consumption.

---

# 3. Service Health Check

### Command

```bash
systemctl status ssh
```

**Purpose:** Displays the current state of the SSH service.

**Observation:** Confirmed that the SSH service is active and running.

---

### Command

```bash
systemctl list-units --type=service --state=running
```

**Purpose:** Lists all active system services.

**Observation:** Verified that essential services are operational.

---

# 4. Log Inspection

### Command

```bash
journalctl -u ssh --no-pager | tail -20
```

**Purpose:** Displays the latest SSH service log entries.

**Observation:** Recent logs showed normal service activity without critical errors.

---

### Command

```bash
tail -20 /var/log/syslog
```

**Purpose:** Reviews the latest system log messages.

**Observation:** No major warnings or failures were observed during the inspection.

---

# 5. Network Verification

### Command

```bash
ss -tuln | grep :22
```

**Purpose:** Verifies whether the SSH service is listening on port 22.

**Observation:** Port 22 was in the LISTEN state, indicating that the SSH service was accepting connections.

---

### Command

```bash
ping localhost
```

**Purpose:** Verifies basic network connectivity.

**Observation:** Local network communication was successful.

---

# Basic Troubleshooting Workflow

### Scenario

Unable to connect to the server through SSH.

### Troubleshooting Steps

1. Verify that the SSH process is running.
2. Check the SSH service status using `systemctl`.
3. Review SSH logs using `journalctl`.
4. Verify that port 22 is listening.
5. Review recent system logs for errors.
6. Restart the SSH service if required.

---

# Key Learnings

* Learned how to inspect Linux processes.
* Understood how to verify service health using `systemctl`.
* Practiced analyzing logs using `journalctl`.
* Verified network ports using `ss`.
* Built confidence in performing basic Linux troubleshooting.

---

# Conclusion

Today's hands-on practice helped me understand the relationship between Linux processes, services, networking, and logs. These skills are fundamental for monitoring systems, diagnosing issues, and performing day-to-day DevOps operations in production environments.
