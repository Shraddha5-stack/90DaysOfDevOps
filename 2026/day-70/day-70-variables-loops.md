# Day 70 — Variables, Facts, Conditionals and Loops

## Objective

Learn how to use:

- Variables
- group_vars
- host_vars
- Ansible Facts
- Conditionals
- Loops
- register
- debug
- Server reports

---

## 1. Variables in Playbooks

Created `variables-demo.yml`.

Variables used:

```yaml
app_name: terraweek-app
app_port: 8080
app_dir: "/opt/{{ app_name }}"
packages:
  - git
  - curl
  - wget
````

The playbook creates the application directory and installs required packages.

### Extra Variables

Variables can be overridden using `-e`:

```bash
ansible-playbook variables-demo.yml -e "app_name=my-custom-app app_port=9090"
```

Result:

```text
Deploying my-custom-app on port 9090 to /opt/my-custom-app
```

---

## 2. group_vars and host_vars

Directory structure:

```text
ansible-practice/
├── group_vars/
│   ├── all.yml
│   ├── web.yml
│   └── db.yml
├── host_vars/
│   └── web-server.yml
└── playbooks/
    └── site.yml
```

### group_vars/all.yml

Common variables for all servers:

```yaml
ntp_server: pool.ntp.org
app_env: development
common_packages:
  - vim
  - htop
  - tree
```

### group_vars/web.yml

Variables for web servers:

```yaml
http_port: 80
max_connections: 1000
web_packages:
  - nginx
```

### group_vars/db.yml

Variables for database servers:

```yaml
db_port: 3306
db_packages:
  - mysql-server
```

### host_vars/web-server.yml

Host-specific variables:

```yaml
max_connections: 2000
custom_message: "This is the primary web server"
```

The host-specific value `2000` overrides the web group value `1000`.

### Simplified Variable Precedence

```text
group_vars/all
      ↓
group_vars
      ↓
host_vars
      ↓
playbook vars
      ↓
task vars
      ↓
extra vars (-e)
```

---

## 3. Ansible Facts

Ansible automatically gathers information about managed servers.

Useful commands:

```bash
ansible web-server -m setup
```

```bash
ansible web-server -m setup -a "filter=ansible_os_family"
```

```bash
ansible web-server -m setup -a "filter=ansible_distribution*"
```

```bash
ansible web-server -m setup -a "filter=ansible_memtotal_mb"
```

```bash
ansible web-server -m setup -a "filter=ansible_default_ipv4"
```

### Five Useful Facts

| Fact                           | Purpose                       |
| ------------------------------ | ----------------------------- |
| `ansible_hostname`             | Hostname of the server        |
| `ansible_distribution`         | Operating system distribution |
| `ansible_distribution_version` | OS version                    |
| `ansible_memtotal_mb`          | Total RAM                     |
| `ansible_default_ipv4.address` | Default IPv4 address          |

Created:

```text
facts-demo.yml
```

The playbook displays hostname, OS, RAM, IP address and network interfaces.

---

## 4. Conditionals

Created:

```text
conditional-demo.yml
```

Examples:

```yaml
when: "'web' in group_names"
```

Installs Nginx only on web servers.

```yaml
when: "'db' in group_names"
```

Installs MySQL only on database servers.

```yaml
when: ansible_distribution == "Ubuntu"
```

Runs only on Ubuntu.

```yaml
when: ansible_memtotal_mb < 1024
```

Displays a warning when RAM is below 1 GB.

### AND condition

```yaml
when:
  - "'web' in group_names"
  - ansible_memtotal_mb >= 512
```

### OR condition

```yaml
when: "'web' in group_names or 'app' in group_names"
```

---

## 5. Loops

Created:

```text
loops-demo.yml
```

Loops were used to:

* Create multiple users
* Create multiple directories
* Install multiple packages
* Display information for each user

Example:

```yaml
loop: "{{ users }}"
```

Users created:

```text
deploy
monitor
appuser
```

Application directories:

```text
/opt/app/logs
/opt/app/config
/opt/app/data
/opt/app/tmp
```

Packages:

```text
git
curl
unzip
jq
```

### Ubuntu Adaptation

The original exercise used the `wheel` group.

Because the lab servers are Ubuntu, `sudo` was used instead.

---

## 6. Server Report

Created:

```text
server-report.yml
```

The playbook combines:

* Ansible Facts
* Variables
* `register`
* `debug`
* Conditionals
* `copy`
* Linux commands

Commands used:

```bash
df -h /
```

```bash
free -m
```

```bash
systemctl list-units --type=service --state=running --no-pager
```

The results are registered and included in the server report.

Reports are saved as:

```text
/tmp/server-report-<hostname>.txt
```

Example:

```text
/tmp/server-report-ip-10-0-1-171.txt
```

---

## Screenshots

```text
screenshots/
├── 01-variable-override.png
├── 02-group-host-vars.png
├── 03-facts-demo.png
├── 04-conditionals.png
├── 05-loops-demo.png
└── 06-server-report.png
```

---

## Key Learnings

### Variables

Variables make playbooks reusable and configurable.

### group_vars

Used to define variables for groups of hosts.

### host_vars

Used for host-specific configuration.

### Facts

Facts provide information automatically collected from managed servers.

### Conditionals

Conditionals allow tasks to execute only when specific conditions are true.

### Loops

Loops avoid repetitive tasks and allow Ansible to process multiple items dynamically.

### register

`register` stores the output of a task in a variable.

### debug

`debug` is useful for displaying variables and troubleshooting playbooks.

---

## Day 70 Summary

Day 70 focused on making Ansible playbooks more dynamic and intelligent.

Completed:

* [x] Variables
* [x] Extra variables
* [x] group_vars
* [x] host_vars
* [x] Variable precedence
* [x] Ansible Facts
* [x] Conditionals
* [x] AND / OR conditions
* [x] Loops
* [x] register
* [x] debug
* [x] Server report

````

