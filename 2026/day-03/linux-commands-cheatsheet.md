# Linux Commands Cheat Sheet

## Process Management

| Command                | Description                                             |
| ---------------------- | ------------------------------------------------------- |
| `ps`                   | Display currently running processes.                    |
| `ps -ef`               | Show all running processes with detailed information.   |
| `top`                  | Monitor CPU, memory, and active processes in real time. |
| `htop`                 | Interactive process viewer (if installed).              |
| `kill <PID>`           | Gracefully stop a process using its Process ID.         |
| `kill -9 <PID>`        | Forcefully terminate a process.                         |
| `pkill <process_name>` | Stop a process by its name.                             |
| `jobs`                 | List background jobs in the current shell.              |
| `bg`                   | Resume a suspended job in the background.               |
| `fg`                   | Bring a background job to the foreground.               |

---

## File System

| Command                     | Description                                                        |
| --------------------------- | ------------------------------------------------------------------ |
| `pwd`                       | Display the current working directory.                             |
| `ls -la`                    | List all files, including hidden files, with detailed information. |
| `cd <directory>`            | Change the current directory.                                      |
| `mkdir <directory>`         | Create a new directory.                                            |
| `touch <file>`              | Create an empty file.                                              |
| `cp <source> <destination>` | Copy files or directories.                                         |
| `mv <source> <destination>` | Move or rename files.                                              |
| `rm <file>`                 | Delete a file.                                                     |
| `rm -r <directory>`         | Delete a directory and all its contents.                           |
| `cat <file>`                | Display the contents of a file.                                    |
| `head <file>`               | Show the first 10 lines of a file.                                 |
| `tail -f <file>`            | Monitor log files in real time.                                    |
| `grep "text" <file>`        | Search for specific text in a file.                                |
| `find . -name "filename"`   | Search for files by name.                                          |
| `chmod 755 <file>`          | Modify file permissions.                                           |
| `chown user:user <file>`    | Change the owner of a file.                                        |
| `du -sh <directory>`        | Display the size of a directory.                                   |
| `df -h`                     | Show available and used disk space.                                |

---

## Networking Commands

| Command                    | Description                                             |
| -------------------------- | ------------------------------------------------------- |
| `ping google.com`          | Check connectivity to another host.                     |
| `ip addr`                  | Display network interface and IP address details.       |
| `hostname -I`              | Show the system's IP address.                           |
| `curl https://example.com` | Retrieve data from a web server or API.                 |
| `dig google.com`           | Perform a DNS lookup.                                   |
| `nslookup google.com`      | Find the IP address of a domain.                        |
| `ss -tuln`                 | Display listening ports and active network connections. |
| `traceroute google.com`    | Show the route packets take to a destination.           |

---

## My Most Frequently Used Commands

* `pwd` – Check my current directory.
* `ls -la` – View files and permissions.
* `grep` – Search for specific text in files.
* `tail -f` – Monitor application logs.
* `top` – Monitor running processes.
* `ip addr` – Check network configuration.
* `curl` – Test APIs and web services.

---

## Key Takeaway

Linux commands are essential for every DevOps Engineer. Understanding process management, file system operations, and networking commands helps troubleshoot issues quickly and manage servers efficiently. This cheat sheet will serve as a quick reference during my DevOps learning journey.
