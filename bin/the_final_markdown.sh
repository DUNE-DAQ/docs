#!/bin/bash

here=$(cd $(dirname $(readlink -f ${BASH_SOURCE})) && pwd)

# Reverse alphabetical order so the packages in the drop-down menu will appear in regular alphabetical order

# ...alphabetical, with the exception of the packages which are used
# for package development themselves

package_list="trigemu serialization restcmd readout rcif opmonlib nwqueueadapters minidaqapp logging listrev ipm ers dfmodules dfmessages dataformats cmdlib appfwk styleguide daq-release daq-cmake daq-buildtools"

mkdocs_yml="$here/../mkdocs.yml"

if [[ -e $mkdocs_yml ]]; then
    echo "You need to delete the existing $mkdocs_yml file before running this script, " >&2
    echo "since it will (re)construct $mkdocs_yml" >&2
    exit 4
fi

packages_dir="$here/../docs/packages"
docs_dir="$here/../docs"

if [[ -d $packages_dir ]]; then
    echo "You need to delete the existing $packages_dir directory before running this script, " >&2
    echo "since it will (re)construct the $packages_dir directory" >&2
    exit 5
fi

cp $here/mkdocs_skeleton.yml $mkdocs_yml

mkdir $packages_dir

tmpdir=$(mktemp -d)

if [[ -d $tmpdir ]]; then
    cd $tmpdir
else
    echo "Unable to create temporary directory $tmpdir; exiting..." >&2
    exit 3
fi

function massage() {

    markdown_file=$1

    if ! [[ "$markdown_file" =~ .*README.md$ ]]; then
	header=$( echo $markdown_file | sed -r 's!.*/(.*)!\1!;s/\-/ /g;s/\.md$//' )
    else
	package=$( echo $markdown_file | sed -r 's!.*/([^/]+)/README.md!\1!' )
	header="$package README"
    fi

    # Translation of the snippet below: "If the first non-empty,
    # non-italics-statement line in the file doesn't begin with a
    # single #, i.e., isn't a main title, then add one manually"

    if [[ -n $( sed -r -n '0,/^\s*\#[^\#]/{/^\s*\#[^\#]/d;/^\s*_/d;/^\s*$/d;p}' $markdown_file ) ]]; then
	sed -r -i "1s/^/# $header\n/"  $markdown_file 
    fi

    # JCF, Mar-5-2021

    # What I've discovered is that GitHub wiki pages recognize
    # indentations of three characters as implying a sublevel in a ToC,
    # but MkDocs doesn't. Furthermore, if a line starts with a bullet (*),
    # MkDocs won't interpret it as a bullet unless there's an empty line
    # above it.

    sed -r -i 's/^(\*.*)$/\n\1/;s/^ {2,4}(\*.*)/    \1/;s/^ {5,}(\*.*)/        \1/' $markdown_file
    sed -r -i 's/^([0-9]+\..*)/\n\1/' $markdown_file
    sed -r -i 's/^([0-9]+\..*)/\n\1/;s/^ {2,4}([0-9]+\.*)/    \1/;' $markdown_file

    # JCF, Mar-25-2021
    # Convert wiki syntax of the form [[link name][other_markdown_page.md]] to [link name](other_markdown_page.md)
    
    sed -r -i 's/\[\[(.+)\|([^#]+).*\]\]/[\1](\2.md)/' $markdown_file 

}

# JCF, Mar-29-2021
# n.b. If you alter the output of this function, make SURE that lines_in_trailer gets set to the correct value

function add_trailer() {
    
    package=$1
    packagefile=$2

    # Chop off any existing trailer
    lines_in_trailer_minus_one=10
    line_from_trailer="Last git commit to the markdown source of this page"

    if [[ -n $( grep "$line_from_trailer" $packagefile ) ]]; then
	# See https://stackoverflow.com/questions/13380607/how-to-use-sed-to-remove-the-last-n-lines-of-a-file
	sed -i "$(($(wc -l < $packagefile)-$lines_in_trailer_minus_one)),\$d" $packagefile
    fi

    echo >> $packagefile
    echo "-----" >> $packagefile
    echo >> $packagefile
    echo "_Last git commit to the markdown source of this page:_" >> $packagefile
    echo >> $packagefile
    echo >> $packagefile
    echo "_"$(git log -1 $packagefile | sed -r -n 's/^(Author.*)\s+\S+@.*/\1/p' )"_" >> $packagefile
    echo >> $packagefile
    echo "_"$(git log -1 $packagefile | grep Date )"_" >> $packagefile
    echo >> $packagefile
    echo "_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/$package/issues](https://github.com/DUNE-DAQ/$package/issues)_" >> $packagefile
}

cd $docs_dir
#for docsfile in $( ls -1 *.md ) ; do
#     if [[ -n $( git diff HEAD -- $docsfile ) ]]; then
# 	echo "Please manually commit changes to $docsfile (and any other markdown files in $docs_dir) so that"
# 	echo "info this script adds about modification time to the file is correct. Exiting..."
# 	exit 5
#     fi
#done

for docsfile in $( ls -1 *.md) ; do
    add_trailer docs $docs_dir/$docsfile
done

for package in $package_list ; do
    
    cd $tmpdir
    cmd="git clone https://github.com/DUNE-DAQ/$package"
    $cmd
    
    if [[ "$?" != "0" ]]; then
	echo "Error calling \"$cmd\"; exiting..." >&2
	exit 1
    fi

    cd $tmpdir/$package
    git checkout johnfreeman/dont-readme 2>/dev/null  # OK if this fails, just trying to see if the branch is available for developer purposes
    echo $tmpdir/$package

    if [[ -d $tmpdir/$package/docs/ || -e $tmpdir/$package/README.md ]]; then
	sed -r -i '/^\s*-\s*Packages\s*:.*/a \       - '$package':' $here/../mkdocs.yml
	mkdir -p $packages_dir/$package
    else
	echo "No docs/ subdirectory or README.md found for $package; no documentation will be generated" >&2
	continue
    fi

    # Add provenance of each markdown file

    for packagefile in $( find . -name "*.md" ); do
	add_trailer $package $packagefile
    done

    if [[ -d $tmpdir/$package/docs/ && -n $(find $tmpdir/$package/docs -name "*.md" ) ]]; then
	echo "Found a docs/ subdirectory in repo $package, ignoring any README.md in the base of the repo"

	cp -rp $tmpdir/$package/docs/* $packages_dir/$package 

	if [[ "$?" != 0 ]]; then
	    echo "There was a problem copying the contents of $tmpdir/$package/docs into $packages_dir/$package ; exiting..." >&2
	    exit 2
	fi

	mdfilelist=""
	if [[ -n $( find  $packages_dir/$package -name "README.md" ) ]]; then
	    mdfilelist="$packages_dir/$package/README.md"
	fi
	mdfilelist=$( find $packages_dir/$package -name "*.md" -not -name "README.md" | sort --reverse )" $mdfilelist"

	for mdfile in $mdfilelist; do
	    massage $mdfile
	    
	    mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	    pagename=$( echo $mdfile | sed -r 's!^.*/(.*).md$!\1!' )
	    if [ x"${pagename}" == "xREADME" ]; then
		pagename=$( echo About ${package} )
		echo "+===+++ ${package} ===== ${mdfile} ==== $pagename"
		sed -r -i '/^\s*-\s*'$package'\s*:.*/a \          - '"$pagename"': '$mdfile_relative $here/../mkdocs.yml
	    else
		sed -r -i '/^\s*-\s*'$package'\s*:.*/a \          - '$mdfile_relative $here/../mkdocs.yml
	    fi

	done

    else # No docs/ directory with markdown files found
	if [[ -e $tmpdir/$package/README.md ]]; then
	    cp -p $tmpdir/$package/README.md $packages_dir/$package
	    mdfile=$packages_dir/$package/README.md 
	    massage $mdfile
	    mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	    sed -r -i 's!^(\s*)-(\s*)'$package'(\s*):!\1-\2'$package'\3: '$mdfile_relative'!' $here/../mkdocs.yml
	fi
    fi

done

if [[ -d $tmpdir && "$tmpdir" =~ ^/tmp/.*$ ]]; then
    rm -rf $tmpdir
fi

