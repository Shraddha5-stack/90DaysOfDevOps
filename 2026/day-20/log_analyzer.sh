#!/bin/bash

# Log Analyzer Script
# Day 20 - 90DaysOfDevOps


LOG_FILE=$1


# Task 1: Input Validation

if [ -z "$LOG_FILE" ]; then
    echo "Error: Please provide log file path"
    echo "Usage: ./log_analyzer.sh <log_file>"
    exit 1
fi


if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File does not exist: $LOG_FILE"
    exit 1
fi


DATE=$(date +%Y-%m-%d)

REPORT="log_report_$DATE.txt"


echo "Analyzing Log File: $LOG_FILE"


# Total Lines

TOTAL_LINES=$(wc -l < "$LOG_FILE")


# Task 2: Error Count

ERROR_COUNT=$(grep -Ei "ERROR|Failed" "$LOG_FILE" | wc -l)


echo ""
echo "------------------------------"
echo "Total Errors Found: $ERROR_COUNT"
echo "------------------------------"


# Task 3: Critical Events

echo ""
echo "------ Critical Events ------"

grep -n "CRITICAL" "$LOG_FILE"



# Task 4: Top Error Messages

echo ""
echo "------ Top 5 Error Messages ------"


grep "ERROR" "$LOG_FILE" | \
awk '{$1=$2=$3=""; print}' | \
sort | uniq -c | sort -rn | head -5



# Task 5: Generate Report


{

echo "================================"
echo "Log Analysis Report"
echo "================================"

echo ""

echo "Date of Analysis: $DATE"

echo "Log File: $LOG_FILE"

echo "Total Lines Processed: $TOTAL_LINES"

echo "Total Error Count: $ERROR_COUNT"


echo ""

echo "------ Top 5 Error Messages ------"

grep "ERROR" "$LOG_FILE" | \
awk '{$1=$2=$3=""; print}' | \
sort | uniq -c | sort -rn | head -5


echo ""

echo "------ Critical Events ------"

grep -n "CRITICAL" "$LOG_FILE"


} > "$REPORT"



echo ""

echo "Report Generated: $REPORT"



# Optional Archive Feature

mkdir -p archive

mv "$LOG_FILE" archive/


echo "Log file moved to archive directory"
