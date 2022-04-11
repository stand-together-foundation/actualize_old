#!/bin/bash

# Login to 1Password. 
# Assumes you have installed the OP CLI and performed the initial configuration
# For more details see https://support.1password.com/command-line-getting-started/
eval $(op signin --account stfimpact)

# Current setup uses a 1Password type of 'Notes' and stores all records within a 
# single entry. 
ev=`op item get "actualize" --vault "data-science" --fields notesPlain` 

for row in $(echo ${ev}); do
    _envvars() {
        echo ${row}
    } 
    export $(echo $(_envvars))
done

echo "Environment Variables Set"
