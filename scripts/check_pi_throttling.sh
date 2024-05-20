#!/bin/bash

# Script Name: check_pi_throttling.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:08:40+02:00
# Version: 1.0

# Description: This script checks the throttling status of a Raspberry Pi by
# querying the vcgencmd tool.

# Usage: ./check_pi_throttling.sh

# Flag Bits
UNDERVOLTED=0x1
CAPPED=0x2
THROTTLED=0x4
SOFT_TEMPLIMIT=0x8
HAS_UNDERVOLTED=0x10000
HAS_CAPPED=0x20000
HAS_THROTTLED=0x40000
HAS_SOFT_TEMPLIMIT=0x80000

# Text Colors
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)

# Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"

# Get Status, extract hex
STATUS=$(vcgencmd get_throttled)
STATUS=${STATUS#*=}

echo -n "Status: "
((STATUS != 0)) && echo "${RED}${STATUS}${NC}" || echo "${GREEN}${STATUS}${NC}"
echo ""

echo "Undervolted:"
echo -n "Now: "
((STATUS & UNDERVOLTED != 0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "Run: "
((STATUS & HAS_UNDERVOLTED != 0)) && echo "${BAD}" || echo "${GOOD}"
echo ""

echo "Throttled:"
echo -n "Now: "
((STATUS & THROTTLED != 0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "Run: "
((STATUS & HAS_THROTTLED != 0)) && echo "${BAD}" || echo "${GOOD}"
echo ""

echo "Frequency Capped:"
echo -n "Now: "
((STATUS & CAPPED != 0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "Run: "
((STATUS & HAS_CAPPED != 0)) && echo "${BAD}" || echo "${GOOD}"
echo ""

echo "Softlimit:"
echo -n "Now: "
((STATUS & SOFT_TEMPLIMIT != 0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "Run: "
((STATUS & HAS_SOFT_TEMPLIMIT != 0)) && echo "${BAD}" || echo "${GOOD}"
echo ""
