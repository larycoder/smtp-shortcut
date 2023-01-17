#!/bin/bash

BASE='/home/postfix';
BIN="$BASE/usr/bin";
SBIN="$BASE/usr/sbin";
MAN="$BASE/usr/local/man";

# Usage
echo """
Usage: source ./postfix-activate.sh

    This script is used to configure and export parameters to run postfix dev.
"""

# Execution path
export PATH="$PATH:$BIN:$SBIN";
export MANPATH="$MAN:$MANPATH";
