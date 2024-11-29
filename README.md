# Assignment 3: Software-Based Solution (Script)
This repository contains the deliverables for Assignment 3 of the Scripting Languages unit, focusing on developing and demonstrating a Bash-based log parsing script with advanced functionality.

## Overview
The objective of this project is to create a Bash script, logparserpro.sh, that extends log parsing capabilities with advanced features such as command-line flag processing, input validation, and file management.

## Script Functionality
### Features
#### 1. Dynamic Input Handling:

Prompts users for the log file and output file names instead of requiring command-line arguments.

#### 2. Command-Line Options:

**-s [arg]:** Filters rows containing a single search term.  
**-d [arg1,arg2]:** Filters rows containing both search terms.  
**-z:** Compresses the output CSV file into a .zip archive (used with -s or -d flags).

#### 3. Output File Management:

Automatically generates a uniquely named output file for every execution to prevent overwrites.  
Displays the number of matching rows in the terminal output.

#### 4. Robust Input Validation:

Ensures all user inputs, including command-line options and prompts, are validated before processing to prevent runtime errors.

### Implementation Details
Developed in Bash with a shebang line of #!/bin/bash.  
Script uses a combination of:  
  - Loops, conditional statements, and functions.  
  - Regular expressions, piping, and command substitution.  

Tested and verified in an Azure Linux VM to ensure compatibility.  
Includes clear and concise inline comments for code clarity.

### Restrictions
Only uses commands and techniques from Modules 1-8 of the course.  
Hardcoding file paths or names is not permitted.  
Test files used during assessment differ from development files to ensure versatility.

## Submission Guidelines

### Script Submission:

Name the script logparserpro.sh.  
Zip the script into a file named [surname]_[student-ID]_CSxxxxx_ASS3.zip.  
Ensure the script is self-contained and compatible with the Azure Linux VM.


## Contact
For any inquiries about the project or code, feel free to connect via LinkedIn or email at kwoodyard173@gmail.com.

