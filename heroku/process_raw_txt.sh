#!/bin/bash

input_dir="./access_logs"    # folder containing .txt files
output_dir="./output_files"  # folder where cleaned and split CSV files will be saved

# ensures the output directory exists
mkdir -p $output_dir

# merges contents of multiple .txt files into one
cat $input_dir/*.txt > $output_dir/merged.txt

# removes duplicate lines
sort $output_dir/merged.txt | uniq > $output_dir/merged_no_duplicates.txt

# filters relevant log entries
grep -P '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2} app\[[^\]]+\]: \d+\.\d+\.\d+\.\d+ - - \[\d{2}/[a-zA-Z]+/\d{4}:\d{2}:\d{2}:\d{2} \+\d{4}\] "\S+ \S+ \S+" \d+ \d+ "\S+" "\S+.*"' $output_dir/merged_no_duplicates.txt > $output_dir/filtered.txt

# cleans and formats the log data
sed -i 's/app\[web\.1\]: //g' $output_dir/filtered.txt
sed -i 's/ - -//g' $output_dir/filtered.txt
sed -i 's/\[[^]]*\]//g' $output_dir/filtered.txt
sed -i 's/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)T\([0-9:.]\+\)/\1 \2/g' $output_dir/filtered.txt
sed -i '/style.css/d' $output_dir/filtered.txt
sed -i '/script\.js/d' $output_dir/filtered.txt
sed -i 's/ "GET/GET/g' $output_dir/filtered.txt
sed -i 's/https:\/\/kabardian-poems-collection-b906b8b63b33\.herokuapp\.com//g' $output_dir/filtered.txt
sed -i 's/HTTP\/1.1"/HTTP\/1.1/g' $output_dir/filtered.txt

# converts spaces to commas for CSV formatting
sed 's/ /,/g' $output_dir/filtered.txt > $output_dir/filtered.csv

# reorders the CSV fields appropriately
awk -F, '{print $3 "," $1 " " $2 "," $4 "," $5 "," $6 "," $7 "," $8 "," $9, "," $10 $11  $12  $13  $14  $15  $16 $17 $18 $19 $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $30}' $output_dir/filtered.csv > $output_dir/filtered_ordered.csv

# trims leading and trailing whitespace
sed -i 's/^[[:space:]]\+//; s/[[:space:]]\+$//' $output_dir/filtered_ordered.csv

# input CSV file for splitting
split_input_file="$output_dir/filtered_ordered.csv"
today=$(date +'%Y-%m-%d')

# reads the CSV file line by line and split into daily files
while IFS=, read -r ip timestamp method resource protocol status size referer user_agent; do
    # extracts the date from the timestamp
    date=$(echo "$timestamp" | cut -d' ' -f1)

    # defines the output filename in the output directory
    output_file="$output_dir/${date}.csv"

    # if the file doesn't exist, adds a header to the new file
    if [[ ! -f "$output_file" ]]; then
        echo "IP,Timestamp,Method,Resource,Protocol,Status,Size,Referer,User-Agent" > "$output_file"
    fi

    # appends the line to the respective file in the output directory
    echo "$ip,$timestamp,$method,$resource,$protocol,$status,$size,$referer,$user_agent" >> "$output_file"
done < "$split_input_file"

# removes today's file if it exists (from previous runs)
if [[ -f "$output_dir/${today}.csv" ]]; then
    rm "$output_dir/${today}.csv"
fi

# removes files below
rm $output_dir/merged.txt
rm $output_dir/merged_no_duplicates.txt
rm $output_dir/filtered.txt
rm $output_dir/filtered.csv
rm $output_dir/filtered_ordered.csv