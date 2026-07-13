# Shell Scripting Cheat Sheet

A quick reference guide for Shell scripting used in DevOps automation.

---

# Quick Reference Table

| Topic | Key Syntax | Example |
|---|---|---|
| Variable | VAR="value" | NAME="DevOps" |
| Argument | $1, $2 | ./script.sh arg1 |
| If Condition | if [ condition ]; then | if [ -f file ]; then |
| For Loop | for i in list; do | for i in 1 2 3; do |
| Function | name(){ } | greet(){ echo "Hi"; } |
| Grep | grep pattern file | grep -i "error" log.txt |
| Awk | awk '{print $1}' | awk -F: '{print $1}' file |
| Sed | sed command | sed 's/old/new/g' file |

---

# 1. Shell Script Basics

## Shebang

Defines which interpreter executes the script.

```bash
#!/bin/bash
```

Example:

```bash
#!/bin/bash
echo "Hello DevOps"
```

---

## Running a Script

Give execute permission:

```bash
chmod +x script.sh
```

Run:

```bash
./script.sh
```

Using bash:

```bash
bash script.sh
```

---

## Comments

Single line comment:

```bash
# This is a comment
```

Inline comment:

```bash
echo "Hello" # printing message
```

---

## Variables

Declare:

```bash
NAME="Shraddha"
```

Use:

```bash
echo $NAME
```

Double quotes preserve spaces:

```bash
echo "$NAME"
```

Single quotes treat value as literal:

```bash
echo '$NAME'
```

---

## User Input

Using read:

```bash
read NAME

echo "Hello $NAME"
```

---

## Command Line Arguments

Example:

```bash
./script.sh DevOps
```

| Variable | Meaning |
|-|-|
| $0 | Script name |
| $1 | First argument |
| $# | Number of arguments |
| $@ | All arguments |
| $? | Exit status |

---

# 2. Operators and Conditionals

## String Comparison

Equal:

```bash
if [ "$a" = "$b" ]
```

Not equal:

```bash
if [ "$a" != "$b" ]
```

Empty:

```bash
-z "$var"
```

Not empty:

```bash
-n "$var"
```

---

## Integer Comparison

```bash
-eq  Equal
-ne  Not equal
-lt  Less than
-gt  Greater than
-le  Less/equal
-ge  Greater/equal
```

Example:

```bash
if [ $age -gt 18 ]
then
echo "Adult"
fi
```

---

## File Operators

```bash
-f file   # regular file
-d dir    # directory
-e file   # exists
-r file   # readable
-w file   # writable
-x file   # executable
-s file   # size greater than zero
```

---

## If Else

```bash
if [ condition ]
then
 command
elif [ condition ]
then
 command
else
 command
fi
```

---

## Logical Operators

AND:

```bash
&&
```

OR:

```bash
||
```

NOT:

```bash
!
```

Example:

```bash
if [ -f file ] && [ -r file ]
then
echo "Readable file"
fi
```

---

## Case Statement

```bash
case $choice in

1)
echo "Start"
;;

2)
echo "Stop"
;;

*)
echo "Invalid"
;;

esac
```

---

# 3. Loops

## For Loop

List:

```bash
for i in 1 2 3
do
echo $i
done
```

C-style:

```bash
for ((i=0;i<5;i++))
do
echo $i
done
```

---

## While Loop

```bash
while [ condition ]
do
command
done
```

---

## Until Loop

Runs until condition becomes true.

```bash
until [ condition ]
do
command
done
```

---

## Break and Continue

Break:

```bash
break
```

Continue:

```bash
continue
```

---

## Loop Files

```bash
for file in *.log
do
echo $file
done
```

---

## Read Command Output

```bash
cat file.txt | while read line
do
echo $line
done
```

---

# 4. Functions

Create function:

```bash
greet()
{
echo "Hello DevOps"
}
```

Call:

```bash
greet
```

Arguments:

```bash
show()
{
echo $1
}

show Linux
```

---

## Return Value

Return:

```bash
return 0
```

Output:

```bash
echo "result"
```

---

## Local Variable

```bash
function test()
{
local name="DevOps"
}
```

---

# 5. Text Processing Commands

## grep

Search:

```bash
grep "ERROR" log.txt
```

Options:

```bash
-i  ignore case
-r  recursive
-c  count
-n  line number
-v  invert match
-E  extended regex
```

---

## awk

Print columns:

```bash
awk '{print $1}' file
```

Field separator:

```bash
awk -F: '{print $1}' /etc/passwd
```

BEGIN:

```bash
awk 'BEGIN{print "Start"}'
```

END:

```bash
awk 'END{print "Done"}'
```

---

## sed

Replace:

```bash
sed 's/old/new/g' file
```

Delete lines:

```bash
sed '5d' file
```

In-place:

```bash
sed -i 's/foo/bar/g' file
```

---

## cut

```bash
cut -d: -f1 /etc/passwd
```

---

## sort

Alphabetical:

```bash
sort file
```

Numeric:

```bash
sort -n file
```

Reverse:

```bash
sort -r file
```

---

## uniq

Remove duplicates:

```bash
uniq file
```

Count:

```bash
uniq -c file
```

---

## tr

Translate:

```bash
tr a-z A-Z
```

Delete:

```bash
tr -d '0-9'
```

---

## wc

Count lines:

```bash
wc -l file
```

Words:

```bash
wc -w file
```

Characters:

```bash
wc -c file
```

---

## head and tail

First lines:

```bash
head file
```

Last lines:

```bash
tail file
```

Follow logs:

```bash
tail -f logfile
```

---

# 6. Useful One Liners

Find files older than 7 days:

```bash
find /logs -type f -mtime +7 -delete
```

Count log files:

```bash
wc -l *.log
```

Replace text:

```bash
sed -i 's/old/new/g' file.txt
```

Check service:

```bash
systemctl status nginx
```

Monitor errors:

```bash
tail -f app.log | grep ERROR
```

---

# 7. Error Handling and Debugging

## Exit Codes

Check status:

```bash
echo $?
```

Success:

```bash
exit 0
```

Failure:

```bash
exit 1
```

---

## set -e

Exit script when command fails:

```bash
set -e
```

---

## set -u

Treat unset variables as errors:

```bash
set -u
```

---

## pipefail

Catch pipeline errors:

```bash
set -o pipefail
```

---

## Debug Mode

Trace commands:

```bash
set -x
```

---

## Trap

Cleanup before exit:

```bash
trap 'cleanup' EXIT
```

---

# Key Learnings

1. Shell scripting helps automate repetitive DevOps tasks.

2. Linux commands can be combined to build powerful automation scripts.

3. Error handling and debugging make scripts reliable.
