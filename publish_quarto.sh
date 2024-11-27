#!/bin/bash

LOG_FILE=log/$(date +"%Y-%m-%d").log

log_message() {
    local type="$1"
    local message="$2"
    local timestamp=$(date +"%H:%M:%S")
    echo "[${timestamp}] ${type} : ${message}" | tee -a "${LOG_FILE}".txt
}

log_message_error() { 
    log_message "ERROR" "$1" 
}

log_message_info() {
    log_message "INFO" "$1"
}

BRANCH_MASTER=$(git branch --show-current)

# Check if the commit message is provided
if [ -z "$1" ]; then
    log_message_error "Please provide a commit message."
    exit 1
fi

# Check if the commit message is the only argument
if [ $# -gt 1 ]; then
    log_message_error "The only admited argument is the commit message."
    log_message_error "If the message is more than a word enclose it with double quotes: \""
    log_message_error "Arguments where '$*'"
    exit 1
fi



# # Commit the changes with the provided message
# git add .
# git commit -m "$1"

# # Push the changes to the main branch
# git push origin main

# # Publish to GitHub Pages using quarto
# quarto publish gh-pages --no-render --no-prompt
