# Linux File I/O Practice

## Objective

The objective of today's practice was to understand the basic Linux file input and output operations using simple commands such as `touch`, `echo`, `tee`, `cat`, `head`, and `tail`.

---

## Step 1: Create a File

### Command

```bash
touch notes.txt
```

**Purpose:** Creates an empty file named `notes.txt`.

---

## Step 2: Write Text to the File

### Command

```bash
echo "Linux is the foundation of DevOps." > notes.txt
```

**Purpose:** Writes the first line to the file. If the file already exists, its previous content is replaced.

---

## Step 3: Append Text

### Command

```bash
echo "Learning Linux commands improves troubleshooting skills." >> notes.txt
```

**Purpose:** Appends a new line to the existing file without overwriting previous content.

---

## Step 4: Write and Display Using tee

### Command

```bash
echo "Practice every day to build confidence." | tee -a notes.txt
```

**Purpose:** Displays the text on the terminal and appends it to the file simultaneously.

---

## Step 5: Read the File

### Command

```bash
cat notes.txt
```

**Purpose:** Displays the complete contents of the file.

---

## Step 6: Read the Beginning of the File

### Command

```bash
head -n 2 notes.txt
```

**Purpose:** Displays the first two lines of the file.

---

## Step 7: Read the End of the File

### Command

```bash
tail -n 2 notes.txt
```

**Purpose:** Displays the last two lines of the file.

---

## Key Learnings

* Created a new file using `touch`.
* Used `>` to write content to a file.
* Used `>>` to append new content.
* Learned how `tee` writes to a file while displaying output.
* Used `cat`, `head`, and `tail` to read file contents efficiently.

---

## Conclusion

Understanding file input and output operations is an essential Linux skill for DevOps Engineers. Configuration files, log files, shell scripts, and automation tasks all depend on reading and writing text files efficiently.

