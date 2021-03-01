#!/bin/bash

here=$(cd $(dirname $(readlink -f ${BASH_SOURCE})) && pwd)

curl -O https://raw.githubusercontent.com/DUNE-DAQ/daq-release/develop/configs/dunedaq-v2.2.0/release_manifest

package_list=$( sed -r -n '/^dune_packages=\(/,/\)/{s/^\s*"(\S+)\s+\S+\s+\S+\s*$/\1/p}' release_manifest | tr "\n" " " | tr "_" "-")
package_list="$package_list daq-buildtools"

packages_dir="$here/../docs/packages"
mkdir -p $packages_dir

tmpdir=$(mktemp -d)

if [[ -d $tmpdir ]]; then
    cd $tmpdir
else
    echo "Unable to create temporary directory $tmpdir; exiting..." >&2
    exit 3
fi

for package in $package_list ; do
    
    cd $tmpdir
    cmd="git clone https://github.com/DUNE-DAQ/$package"
    $cmd
    
    if [[ "$?" != "0" ]]; then
	echo "Error calling \"$cmd\"; exiting..." >&2
	exit 1
    fi

    cd $tmpdir/$package
    git checkout johnfreeman/dont-readme 2>/dev/null  # OK if this fails, just trying to see if the branch is available
    echo $tmpdir/$package

    if [[ -d $tmpdir/$package/docs/ ]]; then
	echo "Found a docs/ subdirectory in repo $package, ignoring any README.md in the base of the repo"

	mkdir -p $packages_dir/$package
	cp -rp $tmpdir/$package/docs/* $packages_dir/$package 

	if [[ "$?" != 0 ]]; then
	    echo "There was a problem copying the contents of $PWD into $packages_dir/$package ; exiting..." >&2
	    exit 2
	fi

	for mdfile in $( find $packages_dir/$package -name "*.md" ); do
	    echo "Handling $mdfile"
	    pagename=$package/$( echo $mdfile | sed -r 's!^.*/(.*).md$!\1!' )
	    mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	    sed -r -i '/^\s*nav\s*:.*/a \    - '$pagename': '$mdfile_relative $here/../mkdocs.yml
	done

	find $packages_dir/$package -type f -not -name "*.md" | xargs -i rm -f {}  # What about *.png, etc.?
    else # No docs/ directory found
	if [[ -e $tmpdir/$package/README.md ]]; then
	    mkdir -p $packages_dir/$package 
	    cp -p $tmpdir/$package/README.md $packages_dir/$package
	    mdfile=$packages_dir/$package/README.md 
	    mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	    sed -r -i '/^\s*nav\s*:.*/a \    - '$package': '$mdfile_relative $here/../mkdocs.yml
	else
	    echo "No docs/ subdirectory or README.md found for $package; no documentation will be generated" >&2
	fi
    fi

done

if [[ -d $tmpdir && "$tmpdir" =~ ^/tmp/.*$ ]]; then
    rm -rf $tmpdir
fi
