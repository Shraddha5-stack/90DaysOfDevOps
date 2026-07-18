# Day 26 – GitHub CLI: Manage GitHub from Your Terminal

## Objective

Learn how to use the GitHub CLI (`gh`) to manage GitHub repositories, issues, pull requests, and GitHub Actions directly from the terminal.

---

# Task 1 – Install and Authenticate

## Commands Used

```bash
gh --version
gh auth login
gh auth status
```

### Screenshot

![GitHub CLI Authentication](screenshots/01-gh-auth-status.png)

## Observations

- Successfully installed GitHub CLI.
- Authenticated using the browser.
- Verified the active GitHub account.

### Question

**What authentication methods does gh support?**

**Answer**

- Web Browser Authentication
- Personal Access Token (PAT)

---

# Task 2 – Working with Repositories

## Commands Used

```bash
gh repo create
gh repo clone Shraddha5-stack/learning_github-
gh repo view
gh repo list
gh repo view --web
gh repo delete
```

### Screenshot

![Repository Operations](screenshots/02-repo-create-clone.png)

### Screenshot

![Repository List](screenshots/03-repo-list.png)

### Screenshot

![Repository Delete](screenshots/04-repo-delete.png)

## Observations

- Created a repository from the terminal.
- Cloned a repository.
- Viewed repository details.
- Listed repositories.
- Opened the repository in the browser.
- Deleted the demo repository.

---

# Task 3 – Issues

## Commands Used

```bash
gh issue create
gh issue list
gh issue view
gh issue close
```

### Screenshot

![Issue Create and List](screenshots/05-issue-create-list.png)

### Screenshot

![Issue Close](screenshots/06-issue-close.png)

## Question

**How could you use gh issue in automation?**

### Answer

The `gh issue` command can automate issue management such as:

- Creating issues
- Listing issues
- Adding comments
- Closing resolved issues

---

# Task 4 – Pull Requests

## Commands Used

```bash
gh pr create
gh pr list
gh pr view
gh pr merge
```

### Screenshot

![Pull Requests](screenshots/07-pull-request.png)

## Questions

### What merge methods does gh pr merge support?

- Merge Commit
- Squash Merge
- Rebase Merge

### How would you review someone else's PR?

```bash
gh pr review <pr-number> --approve
```

---

# Task 5 – GitHub Actions & Workflows

## Commands Used

```bash
gh workflow list
gh run list
gh run view
```

### Screenshot

![GitHub Actions](screenshots/08-workflows.png)

### Question

How could `gh run` and `gh workflow` be useful in CI/CD?

### Answer

They help:

- Monitor workflow executions
- View logs
- Track build status
- Re-run failed workflows
- Automate CI/CD operations

---

# Task 6 – Useful GitHub CLI Commands

## gh api

```bash
gh api user
```

### Screenshot

![GitHub API](screenshots/09-gh-api.png)

---

## gh gist

```bash
gh gist create demo.txt --public
gh gist list
gh gist view <gist-id>
```

---

## gh release

```bash
gh release list
```

---

## gh alias

```bash
gh alias set myrepos "repo list"
gh myrepos
```

---

## gh search repos

```bash
gh search repos kubernetes --limit 5
```

### Screenshot

![Search Repositories](screenshots/10-search-repos.png)

---

# Key Learnings

- Installed and authenticated GitHub CLI.
- Managed repositories directly from the terminal.
- Created and managed Issues.
- Worked with Pull Requests.
- Explored GitHub Actions.
- Learned advanced GitHub CLI commands useful for DevOps automation.

---

# Conclusion

GitHub CLI enables developers and DevOps engineers to manage repositories, issues, pull requests, and GitHub Actions directly from the terminal, making automation and daily workflows faster and more efficient.
