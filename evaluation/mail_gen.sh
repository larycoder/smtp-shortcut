#!/bin/bash

# DATA SECTION
MB_SZ="(1024 * 1160)";
ENVELOPE="data/mail_<SEQ>";
HEADER="""
Subject: Generated mail by automate script on (<DATE>).
""";
BODY="""
(This is body)
"""
END="""
Bye.
"""

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 (TYPE) (NUMBER) (SIZE)

    TYPE: the flag to enable data on-demand,
        supporting 2 type: ODD (on-demand data) and NORM (normal mail).
    NUMBER: the number of generated mail.
    SIZE: the size of single mail count by Mb.

    **NOTE**: manually clean directory \"data\" before running script.
    """;
}

function gen_body() # <MAIL_SIZE>
{
    MAIL_SZ=$1;
    LEN=$(wc -c <<< $BODY);
    TIMES=$(bc <<< "($MAIL_SZ * $MB_SZ) / $LEN");
    for i in $(seq 1 $TIMES); do
        echo $BODY
    done;
    echo $END;
}

function gen_odd_mail()
{

    echo "X-Data-Ondemand: phantom_message";
    echo ${HEADER/'<DATE>'/"$(date)"};
    echo "";
}

function gen_norm_mail()
{
    echo ${HEADER/'<DATE>'/"$(date)"};
    echo "";
}

# MAIN SECTION
if [[ $# != 3 ]]; then
    usage;
    exit 1;
fi;

if [[ $1 == "ODD" ]]; then
    for i in $(seq 1 $2); do
        MY_MAIL=${ENVELOPE/'<SEQ>'/$i};
        gen_odd_mail > $MY_MAIL;
        gen_body $3 >> $MY_MAIL;
    done
elif [[ $1 == "NORM" ]]; then
    for i in $(seq 1 $2); do
        MY_MAIL=${ENVELOPE/'<SEQ>'/$i};
        gen_norm_mail > $MY_MAIL;
        gen_body $3 >> $MY_MAIL;
    done
else
    usage;
fi;
