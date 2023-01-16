#!/bin/bash

BASE='/home/postfix';
SBIN="$BASE/usr/sbin";

# Usage
echo """
Usage: source ./postfix-activate.sh

    This script is used to configure and export parameters to run postfix dev.
"""

# Execution path
export PATH="$PATH:$SBIN":
