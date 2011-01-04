#!/bin/sh
#
# Generate a header file with the current source revision

cd `dirname $0`
srcdir=..
header=$srcdir/include/SDL_revision.h

rev=`sh showrev.sh`
if [ "$rev" != "" ]; then
    echo "#define SDL_REVISION \"$rev\"" >$header.new
    if diff $header $header.new >/dev/null 2>&1; then
        rm $header.new
    else
        mv $header.new $header
    fi
fi
