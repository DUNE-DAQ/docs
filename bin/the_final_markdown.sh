#!/bin/bash
# Hi there

here=$(cd $(dirname $(readlink -f ${BASH_SOURCE})) && pwd)

# Reverse alphabetical order
# for package development themselves

package_list="wibmod utilities trigger timinglibs timing styleguide serialization restcmd readoutmodules readoutlibs rcif rawdatautils opmonlib ndreadoutlibs nddetdataformats nanorc kafkaopmon logging listrev lbrulibs hdf5libs ipm iomanager integrationtest flxlibs fdreadoutlibs fddetdataformats erskafka ers dtpctrllibs dtpcontrols dqm dpdklibs dfmodules dfmessages detdataformats detchannelmaps daqdataformats dbe daqconf daqsystemtest daq-release daq-cmake daq-buildtools daq-assettools coredal cmdlib appfwk appdal"

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

    package=$1
    markdown_file=$2

    if ! [[ "$markdown_file" =~ .*README.md$ ]]; then
	header=$( echo $markdown_file | sed -r 's!.*/(.*)!\1!;s/\-/ /g;s/\.md$//' )
    else
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

    sed -r -i 's/^(\s*\*.*)$/\n\1/;s/^ {2,4}(\*.*)/    \1/;s/^ {5,}(\*.*)/        \1/' $markdown_file
    sed -r -i 's/^([0-9]+\..*)/\n\1/' $markdown_file
    sed -r -i 's/^([0-9]+\..*)/\n\1/;s/^ {2,4}([0-9]+\.*)/    \1/;' $markdown_file

    # JCF, Mar-25-2021
    # Convert wiki syntax of the form [[link name][other_markdown_page.md]] to [link name](other_markdown_page.md)
    
    sed -r -i 's/\[\[(.+)\|([^#]+).*\]\]/[\1](\2.md)/' $markdown_file 

}

function add_trailer() {
    
    package=$1
    packagefile=$2

    echo >> $packagefile
    echo >> $packagefile
    echo "-----" >> $packagefile
    echo >> $packagefile
    echo "<font size=\"1\">" >> $packagefile
    echo "_Last git commit to the markdown source of this page:_" >> $packagefile
    echo >> $packagefile
    echo >> $packagefile
    echo "_"$(git log -1 $packagefile | sed -r -n 's/^(Author.*)\s+\S+@.*/\1/p' )"_" >> $packagefile
    echo >> $packagefile
    echo "_"$(git log -1 $packagefile | grep Date )"_" >> $packagefile
    echo >> $packagefile
    echo "_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/$package/issues](https://github.com/DUNE-DAQ/$package/issues)_" >> $packagefile
    echo "</font>" >> $packagefile
    
}

for package in $package_list ; do
    
    cd $tmpdir
    cmd="git clone https://github.com/DUNE-DAQ/$package"
    $cmd
    
    if [[ "$?" != "0" ]]; then
	echo "Error calling \"$cmd\"; exiting..." >&2
	exit 1
    fi

    cd $tmpdir/$package

    # JCF, Oct-5-2022: we want documentation on the tools used to
    # develop packages to be stable even while DAQ packages are
    # themselves being updated

    if [[ "$package" =~ "daq-buildtools" ]]; then
	git checkout v8.0.0_for_docs2
    elif [[ "$package" =~ "daq-cmake" ]]; then
	git checkout v2.7.0
    else
	git checkout develop
    fi
    echo $tmpdir/$package

    if [[ -d ./docs/ && -n $(find . -name "*.md" )  ]]; then
	mkdir -p $packages_dir/$package
    else
	echo "No docs/ subdirectory for Markdown files found for $package and/or no Markdown files found anywhere; no documentation will be generated" >&2
	continue
    fi

    # Add provenance of each markdown file

    for packagefile in $( find . -name "*.md" -not -type l ); do
	add_trailer $package $packagefile
    done

    # We care about the original Markdown files in non-docs/ directories rather than any symlinks to them
    
    for linkfile in $( find ./docs -type l -name "*.md" ); do
	echo "WARNING: symlinks in ./docs not supported in this script ($linkfile)" >&2
        rm -f $linkfile
    done

    cp -rp ./docs/* $packages_dir/$package/

    if [[ "$?" != 0 ]]; then
	echo "There was a problem copying the contents of $PWD/$package/docs into $packages_dir/$package ; exiting..." >&2
	exit 2
    fi

    for mdfile in $( find . -mindepth 2 -type f  -not -type l  -not -regex ".*\.git.*" -not -regex "\./docs.*" -name "*.md" ); do
	reldir=$( echo $mdfile | sed -r 's!(.*)/.*!\1!' )
        mkdir -p $packages_dir/$package/$reldir
        cp -p $mdfile $packages_dir/$package/$reldir
        if [[ "$?" != "0" ]]; then
	    echo "There was a problem copying $mdfile to $packages_dir/$package/$reldir in $PWD; exiting..." >&2
	    exit 3
	fi

    done

    mdfilelist=""
    if [[ -e $packages_dir/$package/README.md ]]; then
	mdfilelist=" $packages_dir/$package/README.md"
    fi

    mdfilelist=$( find $packages_dir/$package -name "*.md" -not -regex ".*$package/README.md" | sort --reverse --ignore-case )$mdfilelist

    for mdfile in $mdfilelist; do

	massage $package $mdfile
	    
	mdfile_relative=$( echo $mdfile | sed -r 's!^.*/docs/(.*)!\1!' )
	pagename=$( echo $mdfile | sed -r 's!^.*/(.*).md$!\1!' )

        if [[ "$mdfile_relative" == "packages/$package/README.md" ]]; then
	    pagename=$( echo About ${package} )
	    echo "+===+++ ${package} ===== ${mdfile} ==== $pagename"
	    if [[ -z $( sed -r -n '/^\s*-\s*'$package'\s*:.*/p' $here/../mkdocs.yml ) ]]; then
		echo "Error: package \"$package\" is meant to be handled by this script but isn't found in $here/../mkdocs.yml" >&2
		exit 3
	    fi

	    sed -r -i '/^\s*-\s*'$package'\s*:.*/a \             - '"$pagename"': '$mdfile_relative $here/../mkdocs.yml
	else
	    sed -r -i '/^\s*-\s*'$package'\s*:.*/a \             - '$mdfile_relative $here/../mkdocs.yml
	fi

    done
done

#if [[ -d $tmpdir && "$tmpdir" =~ ^/tmp/.*$ ]]; then
#    rm -rf $tmpdir
#fi

