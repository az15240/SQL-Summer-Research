#!/bin/bash

# Check if there are command line arguments
if [ $# -eq 0 ]; then
    option="medium"
else
    option="$1"
fi

exec > output.log
exec 2> error.log

# Function to process files inside a folder
load_raw_data() {
    local folder_name=$1
    cd "$folder_name" || return
    
    # Check if an existing database file exists, and remove if it does
    if [ -f "${folder_name}.db" ]; then
        rm "${folder_name}.db"
    fi
    
    for file in *; do
        # Check if the file is a regular file (not a directory)
        if [ -f "$file" ]; then
            sqlite-utils insert --csv --detect-types "${folder_name}.db" "$file" "$file" --empty-null --silent
        fi
    done
    
    cd ..
}

# Three options for different sizes of the resulting database
case "$option" in
    "simple")
        my_folders=('992' '1010')
    ;;
    "medium")
        my_folders=('277' '253' '1117' '206' '1201' '1144' '1017' '957' '71' '1307' '1010' '1079' '790' '859' '1152' '684' '118' '342' '461' '1318' '1333' '876' '813' '532' '992' '713' '776' '521' '1227' '718' '51' '274' '187' '1078' '1234' '958' '496' '453' '421' '353' '1303' '1118') # a manual listing of folders with data <= 30mb (could be automated later)
    ;;
    "full")
        my_folders=()
        cd data
        for folder in *; do
            echo "$folder"
            if [ -d "$folder" ]; then
                my_folders+=("$folder")
            fi
        done
        cd ..
    ;;
    *)
        option="medium"
        my_folders=('277' '253' '1117' '206' '1201' '1144' '1017' '957' '71' '1307' '1010' '1079' '790' '859' '1152' '684' '118' '342' '461' '1318' '1333' '876' '813' '532' '992' '713' '776' '521' '1227' '718' '51' '274' '187' '1078' '1234' '958' '496' '453' '421' '353' '1303' '1118') # a manual listing of folders with data <= 30mb (could be automated later)
    ;;
esac

cd data

# Iterate over the elements of the array and output them
for folder in "${my_folders[@]}"; do
    folder_name=${folder%/}
    
    if [ -d "$folder_name" ]; then
        load_raw_data "$folder_name"
    fi
done

cd ..


# Attaching data
attach_file="attach.sql"

# Clear the contents of the attach file (if it already exists)
> "$attach_file"

cd data

# Loop over each folder name and write attach statements to the file
for folder_name in "${my_folders[@]}"; do
    echo "ATTACH DATABASE [data/$folder_name/$folder_name.db] AS $folder_name;" >> "../$attach_file"
done

cd ..

case "$option" in
    "simple")
    sqlite3 <<EOF
.read "$attach_file"
.schema
.read "small_testing_script.txt"
.quit
EOF
    ;;
    *)
    sqlite3 <<EOF
.read "$attach_file"
.schema
.read "view_script.txt"
.read "queries.txt"
.quit
EOF
    ;;
esac
