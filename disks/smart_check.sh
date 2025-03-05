#!/bin/bash

# Arrays to store disk statuses
declare -a disks_passed=()
declare -A disks_with_issues=()

# Method to check S.M.A.R.T. status for a single drive
check_smart_status() {
    local DRIVE=$1
    local issues=()

    # Filter out non-S.M.A.R.T. devices
    if [[ $DRIVE == /dev/loop* ]] || [[ $DRIVE == /dev/zram* ]]; then
        return
    fi

    # Attempt to fetch S.M.A.R.T. information
    local SMART_INFO=$(sudo smartctl -A $DRIVE 2>/dev/null)
    if [ $? -ne 0 ]; then
        # Skipping device as it may not support S.M.A.R.T.
        return
    fi

    local STATUS=$(sudo smartctl -H $DRIVE | grep -i "SMART overall-health self-assessment test result" | awk '{print $6}')

    local REALLOCATED=$(echo "$SMART_INFO" | grep -i "Reallocated_Sector_Ct" | awk '{print $10}')
    local PENDING=$(echo "$SMART_INFO" | grep -i "Current_Pending_Sector" | awk '{print $10}')
    local UNCORRECTABLE=$(echo "$SMART_INFO" | grep -i "Uncorrectable_Sector_Ct" | awk '{print $10}')
    local TEMPERATURE=$(echo "$SMART_INFO" | grep -i "Temperature_Celsius" | awk '{print $10}')

    # Validate and compare attributes
    [[ ! $REALLOCATED =~ ^[0-9]+$ ]] && REALLOCATED=0
    [[ ! $PENDING =~ ^[0-9]+$ ]] && PENDING=0
    [[ ! $UNCORRECTABLE =~ ^[0-9]+$ ]] && UNCORRECTABLE=0
    [[ ! $TEMPERATURE =~ ^[0-9]+$ ]] && TEMPERATURE=0

    if [ "$STATUS" != "PASSED" ] && [ "$STATUS" != "OK" ]; then
        issues+=("may be failing. SMART overall-health self-assessment test result: $STATUS")
    fi

    if [ "$REALLOCATED" -gt 0 ]; then
        issues+=("$REALLOCATED reallocated sectors, which could indicate a failing drive.")
    fi

    if [ "$PENDING" -gt 0 ]; then
        issues+=("$PENDING pending sectors, indicating potential failures.")
    fi

    if [ "$UNCORRECTABLE" -gt 0 ]; then
        issues+=("$UNCORRECTABLE uncorrectable sectors. Immediate backup is recommended.")
    fi

    if [ "$TEMPERATURE" -gt 60 ]; then
        issues+=("temperature is too high at $TEMPERATURE°C. Ensure proper cooling.")
    fi

    # Recording disk status
    if [ ${#issues[@]} -eq 0 ]; then
        disks_passed+=("$DRIVE")
    else
        disks_with_issues["$DRIVE"]="${issues[*]}"
    fi
}

# Main script to iterate over each detected disk and check its SMART status
for disk in $(lsblk -nd --output NAME); do
    check_smart_status "/dev/$disk"
done

# Displaying results
echo "Disks that passed the S.M.A.R.T. verification:"
for disk in "${disks_passed[@]}"; do
    echo "- $disk"
done

if [ ${#disks_with_issues[@]} -gt 0 ]; then
    echo "Disks with alerts:"
    for disk in "${!disks_with_issues[@]}"; do
        echo "- $disk: ${disks_with_issues[$disk]}"
    done
fi

