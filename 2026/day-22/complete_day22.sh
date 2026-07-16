#!/bin/bash

echo "Starting Day 22 setup..."

# Day 22 directory
DAY22_DIR="$HOME/90DaysOfDevOps/2026/day-22"

cd "$DAY22_DIR" || exit


echo "Creating screenshots folder..."

mkdir -p screenshots


echo "Copying screenshots..."

cp "$HOME/Pictures/Screenshots/Screenshot from 2026-07-16 23-51-46.png" screenshots/
cp "$HOME/Pictures/Screenshots/Screenshot from 2026-07-16 23-57-43.png" screenshots/
cp "$HOME/Pictures/Screenshots/Screenshot from 2026-07-17 00-00-26.png" screenshots/
cp "$HOME/Pictures/Screenshots/Screenshot from 2026-07-17 00-08-57.png" screenshots/
cp "$HOME/Pictures/Screenshots/Screenshot from 2026-07-17 00-16-10.png" screenshots/


echo "Renaming screenshots..."

cd screenshots || exit

mv "Screenshot from 2026-07-16 23-51-46.png" 01-git-version-config.png
mv "Screenshot from 2026-07-16 23-57-43.png" 02-git-init-status.png
mv "Screenshot from 2026-07-17 00-00-26.png" 03-git-stage-commit.png
mv "Screenshot from 2026-07-17 00-08-57.png" 04-git-log-history.png
mv "Screenshot from 2026-07-17 00-16-10.png" 05-git-workflow.png

cd ..


echo "Adding screenshots into notes..."


cat >> day-22-notes.md <<EOF


# Screenshots


## Task 1: Git Installation and Configuration

![Git Version and Configuration](screenshots/01-git-version-config.png)


## Task 2: Create Git Repository

![Git Init and Status](screenshots/02-git-init-status.png)


## Task 4: Stage and Commit

![Git Stage and Commit](screenshots/03-git-stage-commit.png)


## Task 5: Build Commit History

![Git Log History](screenshots/04-git-log-history.png)


## Task 6: Git Workflow Understanding

![Git Workflow](screenshots/05-git-workflow.png)

EOF


echo "Day 22 screenshot setup completed!"
