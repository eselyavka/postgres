#!/bin/sh

DBS="db1 db2"
ROUSERS="rousers"
RWUSERS="rwusers"

DIR=/var/lib/pgsql

REVOKESQL="$DIR/perm/revoke.sql"
ROGRANTSQL="$DIR/perm/grant_ro.sql"
RWGRANTSQL="$DIR/perm/grant_rw.sql"

RunUser=`id | grep -i root`

if [ -z "$RunUser" ]
then
  printf 'Please run %s as root user\n' $0
  exit 1
fi

if [ ! -e $REVOKESQL ]
then
  echo "File $REVOKESQL not exists exiting...!"
  exit 1
elif [ ! -e $ROGRANTSQL ]
then
  echo "File $ROGRANTSQL not exists exiting...!"
  exit 1
elif [ ! -e $RWGRANTSQL ]
then
  echo "File $RWGRANTSQL not exists exiting...!"
  exit 1
fi

usage() {
  printf '%s <grant> | <revoke>\n' $0
  exit 1
}

if [ $# -ne 1 ]
then
  usage
fi

if [ "$1" = "-h" -o "$1" = "-help" ]
then
  usage
fi

if [ "$1" = "grant" ]
then
  for DB in $DBS
  do
   
    echo "Grant access permisions for databases \"$DB\"..."

    for user in $RWUSERS
    do
      sed "s/role_to_grant/$user/g" < $RWGRANTSQL | su - postgres -c "psql -qXAt $DB | psql $DB" > /dev/null
    done
    
    for user in $ROUSERS
    do
      sed "s/role_to_grant/$user/g" < $ROGRANTSQL | su - postgres -c "psql -qXAt $DB | psql $DB" > /dev/null
    done

  done

elif [ "$1" = "revoke" ]
then 
  for DB in $DBS
  do
   
    echo "Revoke access permisions for databases \"$DB\"..."
    
    for user in $RWUSERS
    do
      sed "s/role_to_revoke/$user/g" < $REVOKESQL | su - postgres -c "psql -qXAt $DB | psql $DB" > /dev/null
    done
    
    for user in $ROUSERS
    do
      sed "s/role_to_revoke/$user/g" < $REVOKESQL | su - postgres -c "psql -qXAt $DB | psql $DB" > /dev/null
    done
  done
fi
echo "Done."
exit 0
