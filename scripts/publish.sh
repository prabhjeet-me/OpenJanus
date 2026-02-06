#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

# Push
./scripts/build.sh push
