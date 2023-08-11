#!/bin/bash

# Function to remove leading "./" from folder names
remove_prefix() {
  echo "$1" | sed 's#^\./##'
}

# Main script
find data -maxdepth 1 -type d | while read -r folder; do
  folder_name=$(remove_prefix "$folder")
  file_count=$(find "$folder" -type f | wc -l)
  file_size=$(du -sh $folder_name | awk '{print $1}')
  echo "$folder_name,$file_count,$file_size"
done | sort -t',' -k3 -rh > folder_file_counts.csv

