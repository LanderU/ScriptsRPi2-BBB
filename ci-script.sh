#!/bin/bash

files_to_check=$(find . -type f -print0 | xargs --null grep -c "/bin/bash" | grep -v ":0" | grep -v "old" | cut -d ":" -f1)
files_invalid=( )
count=0;
for i in ${files_to_check}; do
	shellcheck "${i}" > /dev/null
	result=$?
	if [ ${result} -ne 0 ]; then
		files_invalid[${count}]="${i}"
		count=$((count+1))
	fi
done

if [ ${#files_invalid[@]} -ne 0 ]; then

	echo "Errores"
        for i in ${files_invalid[@]}; do
		echo "$i"
        done
else
	echo "No errores"
fi
