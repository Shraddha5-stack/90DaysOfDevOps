# Linux Fundamentals – Read and Write Text Files

## Objective

Today's goal was to practice basic file input and output operations in Linux. I learned how to create a file, write text, append new content, and read file contents using fundamental Linux commands.

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
echo "Hello Linux" > notes.txt
```

**Purpose:** Writes the first line into the file.

---

## Step 3: Append More Text

### Commands

```bash
echo "My name is Shraddha." >> notes.txt
echo "I am learning DevOps." | tee -a notes.txt
echo "Today is Day 06." >> notes.txt
echo "Linux is easy to learn." >> notes.txt
echo "I am practicing file commands." >> notes.txt
echo "Practice makes me better every day." >> notes.txt
echo "I will become a DevOps Engineer." >> notes.txt
```

**Purpose:**
- `>>` appends text to the existing file.
- `tee -a` displays the text on the terminal and appends it to the file.

---

## Step 4: Read the File

### Command

```bash
cat notes.txt
```

**Purpose:** Displays the complete contents of the file.

---

## Step 5: Display the First Two Lines

### Command

```bash
head -n 2 notes.txt
```

**Purpose:** Shows the first two lines of the file.

---

## Step 6: Display the Last Two Lines

### Command

```bash
tail -n 2 notes.txt
```

**Purpose:** Shows the last two lines of the file.

---

## Key Learnings

- Learned how to create a text file using `touch`.
- Understood the difference between `>` and `>>`.
- Used `tee -a` to write and display output at the same time.
- Practiced reading files using `cat`, `head`, and `tail`.
- Gained confidence in basic Linux file operations.

---

## Conclusion

Basic file operations are an important part of Linux and DevOps. These commands are used daily for working with configuration files, log files, shell scripts, and automation tasks.
