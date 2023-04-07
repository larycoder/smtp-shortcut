# Evaluation
Holding several scripts for evaluation process, including:

1. Data generation.
2. Data feet.
3. Resource indicator.

## Scripts

### Input scripts

1. **mail_gen.sh**: used to generate mail to directory "data" with format is
            "mail_xxx" where "xxx" is mail number. This script help to create
            expected number of mail with approximately expected mail size.
2. **mail_send.sh**: used to send expected number of mail with expected delay
            time between each mail.

### Data processing scripts

1. **./collect_time.sh**: collect raw data about mail transfer time and log it
            down to a log file.
2. **./analyze_time.sh**: aggregate log file to return the mail transfer speed.
