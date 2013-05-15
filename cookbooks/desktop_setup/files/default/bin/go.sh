#!/bin/bash

if [ "$1" == --help ]; then
echo "Usage: go [OPTION]"
echo "Change dir to seleted directory"
echo "" 
echo "  -push [directory] -- add directory to database (fully qualified or .)"
echo "  -clear -- clear database"
echo "  -pop   -- remove a directory from the database"
return
fi

# check for db file
#
dbfile=`which go.sh | sed 's/sh/db/'`
if [ ! -e $dbfile ]; then 
  touch $dbfile
  return
fi

# push a directory
#
if [ "$1" == -push ]; then
 if [ "$2" == "" ] ; then
  echo usage: go -push [directory]
 elif [ "$2" == "." ]; then
    where=$( pwd )
    echo "$where" >> $dbfile
 else
    echo "$2" >> $dbfile
 fi
 return
fi

# clear all
#
if [ "$1" == -clear ] ; then
  echo "" > $dbfile
fi

# remove directroy from db
#
if [ "$1" == -pop ] ; then
select opt in $( cat $dbfile );
do
    dbfile_new=`which go.sh | sed 's/sh/db.new/'`
    grep -v ""$opt\$"" $dbfile > $dbfile_new
    mv $dbfile_new $dbfile
    return
done
fi

# select
#
select opt in $( cat $dbfile );
do
    cd "$opt"
    return
done









