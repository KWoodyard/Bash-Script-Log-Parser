#!/bin/bash

# Student Name: Ky Woodyard
# Student ID: 10632627

BLUE='\033[0;34m' # Variable to colour blue messages
NC='\033[0m' # To turn off colour of the output

# Function to print an error message
print_error() {
    echo "You need to provide the names of two (2) .csv files" # Text to be printed when there is an error with entering files
    echo "- the name of the log file you want processed"
    echo "- the name you want for the .csv file for the processed results to be placed in, e.g."
    echo -e "${BLUE}  ./logparser.sh weblogname.csv outputfilename.csv${NC}" # Example printed in blue to highlight
    echo "Please try again."
}

# Function to print usage instructions
print_usage() {
    echo "Usage: $0 [-s term | -d term1,term2 | [-z]"
    echo "Options:"
    echo "  -s Term filter rows containing a single matching search term"
    echo "  -d Term1,term2 Filter rows containing both matching search terms"
    echo "  -z Compress the results into a zip file"
    exit 1 # Error message to be printed when flags are used improperly
}

# Function to generate a unique output file name
generate_unique_filename() {
    local base_name="results_$(date +%Y%m%d_%H%M%S)" # Base name with current date and time
    local ext=".csv" # File extension
    local counter=1 # Counter for generating unique names
    while [[ -e "${base_name}${ext}" ]]; do # Loop to check if the file already exists
        base_name="results_$(date +%Y%m%d_%H%M%S)_$counter" # Update base name with counter
        ((counter++)) # Increment counter
    done
    echo "${base_name}${ext}" # Return unique file name
}

# Function to process single search term
process_single_search() {
    filtered_file="${output_file%.csv}_filtered.csv" # Create filtered file name based on output file name
    grep "$search_term" "$output_file" > "$filtered_file" # Filter rows matching the search term and save to filtered file
    echo "Filtered results with single search term saved to: $filtered_file" # Inform user about the filtered file
    rm "$output_file" # Remove the unfiltered output file
    output_file="$filtered_file" # Update the output_file variable to the filtered file
    row_count=$(wc -l < "$filtered_file") # Count the number of rows in the filtered file
    echo "Number of matching rows: $row_count" # Print the number of matching rows
}

# Function to process double search terms
process_double_search() {
    filtered_file="${output_file%.csv}_filtered.csv" # Create filtered file name based on output file name
    grep "$search_term1" "$output_file" | grep "$search_term2" > "$filtered_file" # Filter rows matching both search terms and save to filtered file
    echo "Filtered results with double search terms saved to: $filtered_file" # Inform user about the filtered file
    rm "$output_file" # Remove the unfiltered output file
    output_file="$filtered_file" # Update the output_file variable to the filtered file
    row_count=$(wc -l < "$filtered_file") # Count the number of rows in the filtered file
    echo "Number of matching rows: $row_count" # Print the number of matching rows
}

# Function to compress results into a zip file
compress_to_zip() {
    zip_file="${output_file%.csv}.zip" # Create zip file name based on output file name
    zip "$zip_file" "$output_file" # Compress the output file into a zip file
    echo "Compressed file saved to: $zip_file" # Inform user about the zip file
}

# Parsing command-line options
while getopts ":s:d:z" opt; do
    case $opt in
        s)
            search_term="$OPTARG" # Set the single search term
            ;;
        d)
            IFS=',' read -r search_term1 search_term2 <<< "$OPTARG" # Set the double search terms
            ;;
        z)
            zip_requested=true # Set the flag for zip compression
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2 # Handle invalid options
            print_usage # Print usage instructions
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2 # Handle missing argument for options
            print_usage # Print usage instructions
            ;;
    esac
done

# Check if -z flag is used without -s or -d
if [[ "$zip_requested" == true && -z "$search_term" && (-z "$search_term1" || -z "$search_term2") ]]; then
    echo "Error: -z flag cannot be used without -s or -d flag." >&2 # Error message for invalid use of -z
    print_usage # Print usage instructions
fi

# Prompt the user for input and output file names if not provided as arguments
if [[ -z "$input_file" ]]; then
    read -p "Enter the input log file name: " input_file # Prompt for input file name
fi

if [[ ! -f "$input_file" ]] || [[ "$input_file" != *.csv ]]; then # Check if input file exists and is a .csv file
    print_error # Print error message
    exit 1 # Exit the script
fi

if [[ -z "$output_file" ]]; then
    output_file=$(generate_unique_filename) # Generate a unique output file name if not provided
    echo "Generated output file name: $output_file" # Inform user about the generated file name
fi

echo "Processing..." # Proceed with parsing phase of script

echo "IP,Date,Method,URL,Protocol,Status" > "$output_file" # Print the structure of the file at the top of output file

# Extract data from each line and convert to the desired format
while IFS=, read -r ip time url status; do # Reads each line of file and separates 4 fields using IFS
    # Extracting date from the time field without the time component
    date=$(echo "$time" | sed -e 's/\[//' -e 's/:.*//') # Remove leading '[' and everything after the first ':'
    # Extracting method, URL, and protocol
    method=$(echo "$url" | cut -d ' ' -f1) # Extracts the first part of the URL being the method e.g. GET or POST using cut
    url_path=$(echo "$url" | cut -d ' ' -f2) # The -f is cutting the selected field
    protocol=$(echo "$url" | cut -d ' ' -f3) # The delimiter is set as a space
    
    # Removing parameters from the URL and leading '/'
    url=$(echo "$url_path" | sed 's/\?.*//' | sed 's|^/||') # Takes the url_path and removes any parameters in the first sed and any leading slashes in the second sed

    # Write the processed data to the output file
    echo "$ip,$date,$method,$url,$protocol,$status" >> "$output_file" # Writes the output in this structure to the chosen output file
done < <(tail -n +2 "$input_file") # Reads the input file starting from the second line due to the header in original.csv

if [[ ! -z "$search_term" ]]; then
    process_single_search # Process single search term if provided
elif [[ ! -z "$search_term1" && ! -z "$search_term2" ]]; then
    process_double_search # Process double search terms if provided
fi

# Compress results into a zip file if -z flag is used
if [[ "$zip_requested" == true ]]; then
    compress_to_zip # Compress the output file to a zip file
fi

# Count the number of records processed
num_records=$(wc -l < "$input_file") # Starts count of number of records under a variable, increases by one
echo "Total number of records processed: $num_records" # Echos number of records to the terminal upon completion

exit 0