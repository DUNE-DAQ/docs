#!/bin/bash

here=$(cd $(dirname $(readlink -f ${BASH_SOURCE})) && pwd)

package_list="daq-buildtools ipm"
markdown_dir="$here/../docs/packages"

for package in $package_list ; do
    
    cmd="git clone https://github.com/DUNE-DAQ/$package"
    $cmd
    
    if [[ "$?" != "0" ]]; then
	echo "Error calling \"$cmd\"; exiting..." >&2
	exit 1
    fi

    cd $package
    git checkout johnfreeman/dont-readme 2>/dev/null
    

    if [[ -d docs/ ]]; then
	echo "Found a docs/ subdirectory, ignoring any README.md in the base of the repo"
	cd docs/
	cp -rp . $markdown_dir/$package 

	if [[ "$?" == 0 ]]; then
	    cd ..
	else
	    echo "There was a problem copying the contents of $PWD into $markdown_dir/$package ; exiting..." >&2
	    exit 2
	fi

	for mdfile in $( find $markdown_dir/$package -name "*.md" ); do
	    sed -r -i '/^\s*nav\s*:.*/a \    - PageName: $mdfile' $here/../mkdocs.yml
	done

	find $markdown_dir/$package -type f -not -name "*.md" | xargs -i rm -f {}
    else # No docs/ directory found
	if [[ -e README.md ]]; then
	    mkdir -p $markdown_dir/$package 
	    cp -p README.md $markdown_dir/$package
	else
	    echo "No docs/ subdirectory or README.md found for $package; no documentation will be generated" >&2
	fi
    fi

done
