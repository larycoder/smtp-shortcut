# CONFIGURATION SECTION
LOG=$1;
SUBMIT=$2;
DELIVER=$3;
NUM=$4;
DEBUG='F'; # 'T' to print debug and 'F' to not print

OLDIFS='';
ARR=(); # Processed array to store data.

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 <LOG_FILE> <SUBMIT> <DELIVER> <MAIL_NUM>

    LOG_FILE: Path to log file where the raw data is stored.
    SUBMIT: Submission container host name.
    DELIVER: Delivery container host name.
    MAIL_NUM: number of newest mail take count in.
    """;
}

function startIFS() # <IFS_CHAR>
{
    OLDIFS=$IFS;
    IFS=$1;
}

function endIFS()
{
    IFS=$OLDIFS;
}

function get_count() # <ELEMENT_SIZE>
{
    startIFS '|';
    LEN=${#ARR[@]};
    endIFS;
    if (( $(($LEN / $1)) > $NUM )); then
        echo $NUM;
    else
        echo $(($LEN / $1));
    fi;
}

function merge_deliver()
{
    PREV="";
    startIFS $'\n';
    for i in $(cat $LOG | grep "$DELIVER" | tac ); do
        if [[ $i =~ ^\[SUBJECT\] && $PREV =~ ^\[DELIVER\] ]]; then
            ARR+=($i $PREV);
        fi;
        PREV=$i;
    done;
    endIFS;
}

function merge_submit()
{
    TMP_ARR=();
    LEN=$(bc <<< "${#ARR[@]} / 2 - 1");
    for i in $(seq 0 $LEN); do
        D_TIME=${ARR[$(($i * 2 + 1))]};
        ID=$(sed "s/^.*$DELIVER: \[Subject/$SUBMIT: \[Subject/g" <<< ${ARR[$(($i * 2))]});
        SUBJECT=$(sed "s/^.*\[Subject/\[Subject/g" <<< $ID);
        LINE=$(grep -nF "$ID" $LOG | tail -n1 | sed 's/:.*$//g');
        S_TIME=$(sed -n "$(($LINE+1))p" $LOG);

        if [[ $DEBUG == 'T' ]]; then
            echo "SUBJECT ### $SUBJECT";
            echo "DELIVER ### $D_TIME";
            echo "SUBMIT ### $S_TIME";
        fi;

        D_TIME=$(sed "s/^.*$DELIVER: //1" <<< $D_TIME);
        S_TIME=$(sed "s/^.*$SUBMIT: //1" <<< $S_TIME);
        startIFS '|';
        TMP_ARR+=($SUBJECT $D_TIME $S_TIME);
        endIFS;
    done;
    startIFS '|';
    ARR=(${TMP_ARR[@]});
    endIFS;
}

function time_elapse_cal()
{
    TMP_ARR=();
    for i in $(seq 0 $(($(get_count 3) - 1))); do
        startIFS '|';
        SUBJET=${ARR[$(($i * 3))]};
        D_TIME=${ARR[$(($i * 3 + 1))]};
        S_TIME=${ARR[$(($i * 3 + 2))]};
        E_TIME=$(bc <<< "$D_TIME - $S_TIME");

        if [[ $DEUBG == 'T' ]]; then
            echo "SUBJET ### $SUBJET";
            echo "D_TIME ### $D_TIME";
            echo "S_TIME ### $S_TIME";
        fi;

        TMP_ARR+=($SUBJET $E_TIME);
        endIFS;
    done;

    startIFS '|';
    ARR=(${TMP_ARR[@]});
    endIFS;
}

function print_csv()
{
    echo 'subject,elapsed';

    # Print data as CSV
    for i in $(seq 0 $(($(get_count 2) - 1))); do
        startIFS '|';
        echo "${ARR[$(($i*2))]},${ARR[$(($i*2+1))]}";
        endIFS;
    done;
}

# MAIN SECTION
if [[ $# != 4 ]]; then
    usage;
    exit 1;
fi;

merge_deliver;
merge_submit;
time_elapse_cal;
print_csv;
