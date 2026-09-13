# Day 71 — Ansible Roles, Galaxy, Templates and Vault

## 📌 Objective

The goal of Day 71 was to learn how to build reusable and secure Ansible automation using:

* Jinja2 Templates
* Ansible Roles
* Ansible Galaxy
* Ansible Vault
* Handlers
* Variables
* Secure secret management
* Combining Roles + Templates + Vault

---

# 1. Jinja2 Templates

## What is a Jinja2 Template?

Jinja2 templates are dynamic configuration files used by Ansible.

Instead of hardcoding values, we can use variables:

```jinja2
{{ variable_name }}
```

Example:

```jinja2
server_name {{ ansible_hostname }};
root /var/www/{{ app_name }};
```

Ansible replaces the variables with actual values when the template is deployed.

---

## Template Example

File:

```text
templates/nginx-vhost.conf.j2
```

Example:

```nginx
# Managed by Ansible -- do not edit manually
server {
    listen {{ http_port | default(80) }};
    server_name {{ ansible_hostname }};

    root /var/www/{{ app_name }};
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/{{ app_name }}_access.log;
    error_log /var/log/nginx/{{ app_name }}_error.log;
}
```

---

## Template Module

Ansible uses the `template` module to copy and process Jinja2 templates:

```yaml
- name: Deploy configuration
  template:
    src: nginx-vhost.conf.j2
    dest: /etc/nginx/conf.d/myapp.conf
```

---

# 2. Ansible Role Structure

An Ansible Role provides a standard structure for organizing automation.

Role was initialized using:

```bash
ansible-galaxy init roles/webserver
```

The structure is:

```text
roles/
└── webserver/
    ├── defaults/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── tasks/
    │   └── main.yml
    ├── templates/
    ├── vars/
    │   └── main.yml
    ├── files/
    ├── meta/
    └── README.md
```

### Important directories

| Directory    | Purpose           |
| ------------ | ----------------- |
| `tasks/`     | Main tasks        |
| `handlers/`  | Handlers          |
| `templates/` | Jinja2 templates  |
| `defaults/`  | Default variables |
| `vars/`      | Role variables    |
| `files/`     | Static files      |
| `meta/`      | Role metadata     |

---

# 3. Custom Webserver Role

The custom role was created for installing and configuring Nginx.

## defaults/main.yml

```yaml
---
http_port: 80
app_name: myapp
max_connections: 512
```

These are default values and can be overridden.

---

## tasks/main.yml

The role performs the following operations:

1. Install Nginx
2. Deploy Nginx configuration
3. Deploy virtual host configuration
4. Create application web root
5. Deploy index page
6. Start and enable Nginx

Example:

```yaml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present
    update_cache: true

- name: Deploy Nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: Restart Nginx

- name: Deploy vhost config
  template:
    src: vhost.conf.j2
    dest: "/etc/nginx/conf.d/{{ app_name }}.conf"
    owner: root
    group: root
    mode: '0644'

- name: Create web root
  file:
    path: "/var/www/{{ app_name }}"
    state: directory
    mode: '0755'

- name: Deploy index page
  template:
    src: index.html.j2
    dest: "/var/www/{{ app_name }}/index.html"
    mode: '0644'

- name: Start and enable Nginx
  service:
    name: nginx
    state: started
    enabled: true
```

---

# 4. Handlers

Handlers are special tasks that run when notified.

Example:

```yaml
handlers:
  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

The task can notify the handler:

```yaml
notify: Restart Nginx
```

The handler runs only when the related task reports a change.

This helps avoid unnecessary service restarts.

---

# 5. Using the Role

The role was used from:

```text
site.yml
```

Example:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true

  roles:
    - role: webserver
      vars:
        app_name: terraweek
        http_port: 80
```

The role successfully installed and configured Nginx.

---

# 6. Ansible Galaxy

Ansible Galaxy is a community platform for discovering and installing reusable Ansible roles.

Search for Nginx roles:

```bash
ansible-galaxy search nginx
```

A large number of community roles were available.

---

## Installing a Galaxy Role

Docker role installed:

```bash
ansible-galaxy install geerlingguy.docker
```

Installed version:

```text
geerlingguy.docker 8.0.0
```

Verify installed roles:

```bash
ansible-galaxy list
```

---

## Docker Galaxy Playbook

File:

```text
docker-setup.yml
```

```yaml
---
- name: Install Docker using Galaxy role
  hosts: app
  become: true

  roles:
    - geerlingguy.docker
```

Run:

```bash
ansible-playbook docker-setup.yml
```

Docker installation completed successfully.

Verification:

```bash
ansible app-server -b -m shell -a "docker --version"
```

Docker was installed and running successfully.

---

# 7. Ansible Vault

## What is Ansible Vault?

Ansible Vault is used to encrypt sensitive information such as:

* Passwords
* API keys
* Database credentials
* Tokens
* Private configuration values

Instead of storing secrets as plain text, Ansible Vault encrypts them.

---

# 8. Creating a Vault File

The Vault file was created at:

```text
group_vars/app/vault.yml
```

Example variables:

```yaml
db_username: devopsuser
db_password: <encrypted-secret>
db_host: 10.0.1.165
```

The file is encrypted using:

```bash
ansible-vault create group_vars/app/vault.yml
```

---

# 9. Viewing an Encrypted Vault

To safely view the contents:

```bash
ansible-vault view group_vars/app/vault.yml
```

Ansible asks for the Vault password and decrypts the file temporarily for viewing.

The encrypted file itself remains encrypted on disk.

---

# 10. Using Vault Variables

Example playbook:

```yaml
---
- name: Test Ansible Vault
  hosts: app
  become: true

  tasks:
    - name: Display database username
      debug:
        msg: "Database user is {{ db_username }}"

    - name: Display database host
      debug:
        msg: "Database host is {{ db_host }}"
```

Run:

```bash
ansible-playbook vault-demo.yml --ask-vault-pass
```

The Vault password allows Ansible to decrypt the variables during execution.

---

# 11. Protecting Secrets with no_log

Sensitive values should never be displayed in Ansible output.

Example:

```yaml
- name: Use database password securely
  debug:
    msg: "Database password has been loaded securely"
  no_log: true
```

`no_log: true` prevents sensitive task information from appearing in normal Ansible output.

This is an important security practice.

---

# 12. Combining Roles + Templates + Vault

The final practical exercise combined:

```text
Custom Role
      ↓
Jinja2 Templates
      ↓
Ansible Vault
      ↓
Secure Configuration
      ↓
Nginx
```

Playbook:

```text
secure-webserver.yml
```

Example:

```yaml
---
- name: Deploy secure web server
  hosts: app
  become: true

  roles:
    - role: webserver
      vars:
        app_name: secure-app
        http_port: 80
        app_env: production

  tasks:
    - name: Create secure configuration
      template:
        src: secure-config.j2
        dest: /etc/nginx/conf.d/secure-app-secrets.conf
        owner: root
        group: root
        mode: '0600'
      no_log: true
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

The template used Vault variables:

```jinja2
# Managed by Ansible
# Database configuration

# DB_USER={{ db_username }}
# DB_HOST={{ db_host }}
```

The task used:

```yaml
no_log: true
```

to prevent sensitive information from being exposed in the Ansible output.

---

# 13. Final Playbook Result

The combined playbook completed successfully:

```text
app-server : ok=9 changed=7 unreachable=0 failed=0 skipped=0
```

This confirmed that:

* Custom role worked
* Nginx was installed
* Templates were processed
* Vault variables were available
* Secure configuration was created
* Handler restarted Nginx successfully

---

# 14. Nginx Verification

Configuration was tested with:

```bash
ansible app-server -b -m shell -a "nginx -t" --ask-vault-pass
```

Result:

```text
syntax is ok
test is successful
```

Nginx service status was checked with:

```bash
ansible app-server -b -m shell -a "systemctl is-active nginx" --ask-vault-pass
```

Result:

```text
active
```

Therefore the Nginx configuration and service were both working correctly.

---

# 15. Important Commands Learned

## Roles

```bash
ansible-galaxy init roles/webserver
ansible-galaxy list
```

## Galaxy

```bash
ansible-galaxy search nginx
ansible-galaxy install geerlingguy.docker
```

## Vault

```bash
ansible-vault create vault.yml
ansible-vault view vault.yml
ansible-vault edit vault.yml
ansible-vault encrypt vault.yml
ansible-vault decrypt vault.yml
```

## Playbooks

```bash
ansible-playbook site.yml
ansible-playbook vault-demo.yml --ask-vault-pass
ansible-playbook secure-webserver.yml --ask-vault-pass
```

## Verification

```bash
nginx -t
systemctl is-active nginx
```

---

# 16. Screenshots

The following screenshots were captured during Day 71:

```text
07-galaxy-role-install.png
08-docker-version.png
09-docker-service-active.png
10-vault-playbook-success.png
11-combined-roles-templates-vault.png
12-nginx-verification.png
```

---

# 17. Real-World DevOps Use Cases

## 1. Standardized Server Configuration

Roles allow DevOps teams to configure many servers consistently.

Example:

```text
100 web servers
       ↓
Same Ansible Role
       ↓
Same Nginx configuration
```

---

## 2. Environment-Specific Configuration

Jinja2 templates allow different values for:

```text
Development
Staging
Production
```

without maintaining completely separate configuration files.

---

## 3. Secret Management

Ansible Vault can protect:

```text
Database passwords
API tokens
Cloud credentials
Application secrets
```

---

## 4. Reusable Automation

Ansible Galaxy allows teams to reuse community-maintained roles instead of building everything from scratch.

---

# 18. Interview Questions

### Q1. What is an Ansible Role?

An Ansible Role is a standardized directory structure used to organize and reuse Ansible automation.

### Q2. What is Jinja2?

Jinja2 is a templating engine used by Ansible to dynamically generate configuration files using variables.

### Q3. What is Ansible Galaxy?

Ansible Galaxy is a community platform for discovering and installing reusable Ansible roles and collections.

### Q4. What is Ansible Vault?

Ansible Vault encrypts sensitive data used by Ansible, such as passwords, tokens, and credentials.

### Q5. What is `no_log: true`?

It prevents sensitive task information from being displayed in Ansible output.

### Q6. What is the difference between `defaults` and `vars`?

`defaults` contains variables designed to be easily overridden, while `vars` generally has higher precedence and is harder to override.

### Q7. Why use handlers?

Handlers are used for actions such as restarting or reloading services only when a configuration change occurs.

### Q8. Why use templates instead of static files?

Templates allow configuration files to dynamically change based on variables, facts, and environment.

### Q9. How do you install a Galaxy role?

```bash
ansible-galaxy install role_name
```

### Q10. How do you run a playbook using Vault?

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

---

# 19. Day 71 Summary

Today I learned how to build more professional Ansible automation using:

```text
Ansible
   │
   ├── Roles
   │
   ├── Jinja2 Templates
   │
   ├── Ansible Galaxy
   │
   ├── Ansible Vault
   │
   ├── Variables
   │
   ├── Handlers
   │
   └── Secure Automation
```

### Final Outcome

I successfully built a reusable Nginx webserver role, installed a community Docker role from Ansible Galaxy, encrypted secrets with Ansible Vault, used Jinja2 templates for dynamic configuration, protected secret-handling tasks with `no_log`, and combined these concepts into a working secure webserver deployment.

**Day 71 — COMPLETED ✅**
