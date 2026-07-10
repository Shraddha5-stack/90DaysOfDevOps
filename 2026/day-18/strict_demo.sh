#!/bin/bash

set -euo pipefail

echo "Testing set -e"

false

echo "This line will not execute"
