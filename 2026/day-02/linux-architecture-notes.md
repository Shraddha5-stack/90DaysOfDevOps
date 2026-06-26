# Linux Architecture, Processes, and systemd

## Core Components of Linux

* **Hardware:** The physical components such as CPU, RAM, hard disk, and network devices where the Linux operating system runs.

* **Kernel:** The core of the Linux operating system. It manages hardware resources, memory, CPU scheduling, and communication between hardware and software.

* **User Space:** The area where users and applications run. Programs cannot access hardware directly; they communicate with the kernel.

* **Shell:** A command-line interface (CLI) that allows users to interact with the Linux kernel using commands.

* **System Libraries:** Pre-written functions and libraries that applications use to communicate with the kernel.

* **System Utilities:** Built-in tools such as `ls`, `cp`, `mv`, `grep`, and `find` that help perform daily system administration tasks.

* **systemd (Init System):** The first process started during boot (PID 1). It initializes the system, starts services, manages background processes, and restarts failed services when required.

---

# Processes in Linux

A process is an instance of a running program. Every process has a unique **Process ID (PID)**.

Example:

* Running `ping google.com` creates a new process.
* Commands like `ps`, `top`, and `htop` are used to monitor running processes.

## Process States

* **Running (R):** The process is actively executing on the CPU.

* **Sleeping (S):** The process is waiting for an event or resource to become available.

* **Stopped (T):** The process has been paused using signals such as `SIGSTOP` or by pressing `Ctrl + Z`. It can be resumed with `SIGCONT`.

* **Zombie (Z):** The process has finished execution, but its parent process has not yet collected its exit status.

* **Orphan:** A process whose parent has terminated. It is adopted and managed by **systemd (PID 1)**.

---

# What is systemd?

`systemd` is the default service manager in most Linux distributions.

It is responsible for:

* Booting the operating system.
* Starting and stopping services.
* Managing background services (daemons).
* Restarting failed services automatically.
* Viewing system logs using `journalctl`.

Useful command:

```bash
systemctl status ssh
```

---

# 5 Linux Commands Used Daily

* **ps / top** – View running processes, CPU usage, memory usage, and process IDs.

* **systemctl** – Start, stop, restart, enable, or check the status of system services.

* **chmod** – Change file and directory permissions.

* **ssh** – Securely connect to remote Linux servers.

* **df / du** – `df` shows disk space usage, while `du` displays the size of files and directories.

---

# Why This Matters for DevOps

Understanding Linux architecture and processes helps me:

* Troubleshoot application and service failures.
* Monitor CPU, memory, and disk usage.
* Manage services using `systemd`.
* Debug production issues efficiently.
* Build a strong foundation for DevOps and Cloud Engineering.
