#!/bin/bash

# check if log directory exists
if [ ! -d "log" ]; then
    # if not then we try to create it
    mkdir log
    if [ $? -ne 0 ] ; then
        echo "log directory does not exist and can't be created."
        exit 1
    fi
fi

LOG_FILE=log/$(date +"%Y-%m-%d").log

log_message() {
    local type="$1"
    local message="$2"
    local timestamp=$(date +"%H:%M:%S")
    echo "[${timestamp}] ${type}: ${message}" | tee -a "${LOG_FILE}".txt
}

log_message_error() { 
    log_message "ERROR" "$1" 
}

log_message_info() {
    log_message "INFO" "$1"
}

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

# get current branch
BRANCH=$(git branch --show-current 2>/dev/null)
if [ $? -ne 0 ]; then
    log_message_error "git branch --show-current"
    exit 1
fi

# Check if there are some changes to save
# https://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommitted-changes
GS=$(git status --porcelain=v1 2>/dev/null)
if [ $? -eq 128 ]; then
    log_message_error "There is no git repository in current folder."
    log_message_error "Current folder is: $(pwd)"
    exit 1
fi

if [ -z "${GS}" ]; then
    log_message_info "There are no changes to commit."
    exit 0
fi

git add . 2>/dev/null
if [ $? -ne 0 ]; then
    log_message_error "git add ."
    exit 1
else
    log_message_info "git add ."
fi

git commit -m "$1" 2>/dev/null
if [ $? -ne 0 ]; then
    log_message_error "git commit -m \"$1\""
    exit 1
else
    log_message_info "git commit -m \"$1\""
fi

git push origin $BRANCH
if [ $? -ne 0 ]; then
    log_message_error "git push origin $BRANCH"
    exit 1
else
    log_message_info "git push origin $BRANCH"
fi

quarto publish gh-pages --no-prompt
if [ $? -ne 0 ]; then
    log_message_error "quarto publish gh-pages --no-prompt"
    exit 1
else
    log_message_info "quarto publish gh-pages --no-prompt"
fi

exit 0
