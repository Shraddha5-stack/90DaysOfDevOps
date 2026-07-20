# Day 28 – Revision Day (Days 1–27)

## Objective

The objective of Day 28 was to review and reinforce everything learned from Day 1 to Day 27. Instead of learning new concepts, I revisited Linux, Shell Scripting, Git, GitHub, and DevOps fundamentals to identify strengths, improve weak areas, and ensure I can confidently explain and apply the concepts.

---

# Task 1 – Self-Assessment Checklist

## Linux

| Topic | Status |
|--------|--------|
| Navigate file system | ✅ Can do confidently |
| File & directory management | ✅ Can do confidently |
| Process management | ✅ Can do confidently |
| systemd services | ✅ Can do confidently |
| Edit files using nano/vim | ✅ Can do confidently |
| CPU, Memory & Disk troubleshooting | ✅ Can do confidently |
| Linux File System Hierarchy | ✅ Can do confidently |
| User & Group Management | ✅ Can do confidently |
| File Permissions (chmod) | ✅ Can do confidently |
| Ownership (chown/chgrp) | ✅ Can do confidently |
| LVM | 🔄 Need more practice |
| Networking Commands | ✅ Can do confidently |
| DNS, IP, Subnet & Ports | 🔄 Need more practice |

---

## Shell Scripting

| Topic | Status |
|--------|--------|
| Variables & User Input | ✅ |
| Arguments | ✅ |
| Conditional Statements | ✅ |
| Loops | ✅ |
| Functions | ✅ |
| Text Processing (grep, awk, sed) | 🔄 Need more practice |
| Error Handling | 🔄 Need more practice |
| Crontab | ✅ |

---

## Git & GitHub

| Topic | Status |
|--------|--------|
| Git Init, Add, Commit | ✅ |
| Branching | ✅ |
| Push & Pull | ✅ |
| Clone vs Fork | ✅ |
| Merge | ✅ |
| Rebase | 🔄 Need more practice |
| Git Stash | ✅ |
| Cherry Pick | ✅ |
| Reset & Revert | ✅ |
| Branching Strategies | 🔄 Need more practice |
| GitHub CLI | ✅ |

---

# Task 2 – Topics Revisited

I revisited the following topics:

## 1. Linux Logical Volume Manager (LVM)

### What I Revised

- Physical Volume (PV)
- Volume Group (VG)
- Logical Volume (LV)
- Creating, extending, and reducing logical volumes
- Benefits of flexible storage management

---

## 2. Shell Script Error Handling

### What I Revised

- set -e
- set -u
- set -o pipefail
- trap command
- Handling script failures gracefully

---

## 3. Git Rebase & Branching Strategies

### What I Revised

- Git Merge vs Git Rebase
- Interactive Rebase
- GitFlow
- GitHub Flow
- Trunk-Based Development
- Choosing the right workflow for different teams

---

# Task 3 – Quick-Fire Questions

## 1. What does `chmod 755 script.sh` do?

It gives the owner read, write, and execute permissions (7), while the group and others get read and execute permissions (5).

---

## 2. Difference between a process and a service?

A process is a running instance of a program. A service is a background process managed by the operating system, usually through systemd, and often starts automatically during boot.

---

## 3. How do you find which process is using port 8080?

```bash
sudo ss -tulpn | grep :8080
```

or

```bash
sudo lsof -i :8080
```

---

## 4. What does `set -euo pipefail` do?

- `set -e` → Exit immediately if a command fails.
- `set -u` → Treat unset variables as errors.
- `set -o pipefail` → Return the exit status of the first failed command in a pipeline.

Together, these options make shell scripts safer and more reliable.

---

## 5. Difference between `git reset --hard` and `git revert`

`git reset --hard` moves the branch pointer and permanently discards local changes and commits.

`git revert` creates a new commit that reverses the changes without rewriting history, making it safe for shared repositories.

---

## 6. Which branching strategy would you recommend for a team of 5 developers shipping weekly?

GitHub Flow is a good choice because it is simple, encourages pull requests, and supports frequent releases.

---

## 7. What does `git stash` do?

It temporarily saves uncommitted changes so I can switch branches or work on something else without committing unfinished work.

---

## 8. How do you schedule a script to run every day at 3 AM?

```bash
0 3 * * * /path/to/script.sh
```

---

## 9. Difference between `git fetch` and `git pull`

- `git fetch` downloads changes from the remote repository without merging them.
- `git pull` downloads changes and automatically merges them into the current branch.

---

## 10. What is LVM?

Logical Volume Manager (LVM) provides flexible disk management by allowing logical volumes to be resized, extended, or reduced without repartitioning the physical disks.

---

# Task 4 – Repository Verification

Completed the following checks:

- ✅ All Day 1–27 submissions committed and pushed
- ✅ Git commands documentation updated
- ✅ Shell scripting cheat sheet completed
- ✅ GitHub profile cleaned and organized
- ✅ Repository descriptions updated
- ✅ Pinned repositories verified

---

# Task 5 – Teach It Back

## Explaining Git Branches to a Beginner

Imagine you are writing a book with your friends. Instead of everyone editing the same page at the same time, each person creates a separate copy to work on new ideas. These copies are like Git branches. Everyone can make changes independently without affecting the main version. Once the changes are tested and approved, they are merged back into the main branch. This makes collaboration safer and prevents accidental mistakes in the main project.

---

# Key Takeaways

- Revision is essential for retaining technical concepts.
- Practicing commands repeatedly builds confidence.
- Documentation helps reinforce learning.
- Organizing projects and notes makes future revision easier.
- Teaching a concept is one of the best ways to verify understanding.

---

# Conclusion

Day 28 was a valuable opportunity to revisit the concepts learned over the past 27 days. It helped reinforce Linux, Shell Scripting, Git, and DevOps fundamentals while identifying areas that require additional practice. Continuous revision and hands-on practice will strengthen my foundation as I progress further in my DevOps journey.
