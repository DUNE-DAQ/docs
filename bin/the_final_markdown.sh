#!/bin/bash

here=$(cd $(dirname $(readlink -f ${BASH_SOURCE})) && pwd)
tag=dunedaq-v2.2.0

curl -O https://raw.githubusercontent.com/DUNE-DAQ/daq-release/develop/configs/$tag/release_manifest

package_list=$( sed -r -n '/^dune_packages=\(/,/\)/{s/^\s*"(\S+)\s+\S+\s+\S+\s*$/\1/p}' release_manifest | tr "\n" " " | tr "_" "-")
package_list="$package_list daq-buildtools"
rm -f release_manifest

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

    if [[ -d $tmpdir/$package/docs/ || -e $tmpdir/$package/README.md ]]; then
	sed -r -i '/^\s*-\s*Packages\s*:.*/a \       - '$package':' $here/../mkdocs.yml
	mkdir -p $packages_dir/$package
    else
	echo "No docs/ subdirectory or README.md found for $package; no documentation will be generated" >&2
	continue
    fi

    if [[ -d $tmpdir/$package/docs/ && -n $(find $tmpdir/$package/docs -name "*.md" ) ]]; then
	echo "Found a docs/ subdirectory in repo $package, ignoring any README.md in the base of the repo"

	cp -rp $tmpdir/$package/docs/* $packages_dir/$package 

	if [[ "$?" != 0 ]]; then
	    echo "There was a problem copying the contents of $tmpdir/$package/docs into $packages_dir/$package ; exiting..." >&2
	    exit 2
	fi

	for mdfile in $( find $packages_dir/$package -name "*.md" ); do
	    echo "Handling $mdfile"
	    pagename=$( echo $mdfile | sed -r 's!^.*/(.*).md$!\1!' )
	    mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	    sed -r -i '/^\s*-\s*'$package'\s*:.*/a \          - '$pagename': '$mdfile_relative $here/../mkdocs.yml
	done

    else # No docs/ directory found
	if [[ -e $tmpdir/$package/README.md ]]; then
	    cp -p $tmpdir/$package/README.md $packages_dir/$package
	    mdfile=$packages_dir/$package/README.md 
	    mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	    sed -r -i 's!^(\s*)-(\s*)'$package'(\s*):!\1-\2'$package'\3: '$mdfile_relative'!' $here/../mkdocs.yml
	fi
    fi

done

if [[ -d $tmpdir && "$tmpdir" =~ ^/tmp/.*$ ]]; then
    rm -rf $tmpdir
fi
