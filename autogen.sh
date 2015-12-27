#!/bin/sh
# Run this to generate all the initial makefiles, etc.
srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

(test -f $srcdir/configure.ac) || {
	echo "**Error**: Directory "\`$srcdir\'" does not look like the top-level project directory"
	exit 1
}

# Use the style-checker as pre-commit and pre-applypatch hooks
if [ -d $srcdir/.git ]; then
        if [ ! -L $srcdir/.git/hooks/pre-commit ]; then
            ln -s ../../../libgames-support/style-checker $srcdir/.git/hooks/pre-commit && echo "Enabled pre-commit style checker." || :
        fi
        if [ ! -L $srcdir/.git/hooks/pre-applypatch ]; then
            ln -s ../../../libgames-support/style-checker $srcdir/.git/hooks/pre-applypatch && echo "Enabled pre-applypatch style checker." || :
        fi
fi

PKG_NAME=`autoconf --trace "AC_INIT:$1" "$srcdir/configure.ac"`

if [ "$#" = 0 -a "x$NOCONFIGURE" = "x" ]; then
	echo "**Warning**: I am going to run \`configure' with no arguments." >&2
	echo "If you wish to pass any to it, please specify them on the" >&2
	echo \`$0\'" command line." >&2
	echo "" >&2
fi

set -x

aclocal --install || exit 1
intltoolize --force --copy --automake || exit 1
autoreconf --verbose --force --install -Wno-portability || exit 1

if [ "$NOCONFIGURE" = "" ]; then
	$srcdir/configure "$@" || exit 1

	if [ "$1" = "--help" ]; then exit 0 else
		echo "Now type \`make\' to compile $PKG_NAME" || exit 1
	fi
else
	echo "Skipping configure process."
fi

set +x
