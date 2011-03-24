#!/bin/sh

#########################################################################
# This file is freeze.sh shell script
# Copyright (C) 2010, Jaume Nualart & servus.at. Catalunya & Austria. Europe
# Licensed under the GNU GPL 3
# PURPOSE: Create an HTML version of a drupal site from the server were drupal is. 
#          (tested with drupal-5.23 and 6.19)
# Authors: Jaume Nualart, Kenneth Peiruza, Peda (servus.at) & Chris Hager.
# Barcelona - Catalonia - UE - December 2010
# Contact/Comments: jaume AT nualart.cat
#
# This file has comments explaining what the script does. 
# You aso can read a more extended documentation in the file README
#########################################################################

## Requeriments:
# httrack: for mirrowing the site
# Write permissions in:
#            [pth_to_drupa]/[drupal.domain]
#            [/tmp/]


## Configuration (this can be customized) 
# freeze script will work from the directory:
WORKDIR="/home/wachbirn"

# Where is settings.php?
SETTINGS= $LOCALDIR/sites/default/settings.php

###############################################################
# Use: freeze.sh [domain] [local_path]

# 1/14. Checking script parameters
if [ $# -lt 2 ]; then
  echo "Not enough arguments."
  echo "Usage: freeze.sh [domain] [local_path]"
  exit 1
fi

# Fixing vars
DOMAIN=$1
DOMAIN_CLEAN=$( echo $1 | sed 's/^http:\/\///g' | sed 's/\/$//g' )
LOCALDIR=$( echo $2 | sed 's/\/$//g' )

# 2/14. Checking for HTTRACK
X=$( which httrack )
if [ -z $X ]; then
  echo "Please install 'httrack' (eg. 'sudo apt-get install httrack')"
  exit 1
fi

echo ""

# 3/14. Start checking
cd $WORKDIR
mkdir -p drupalfreeze
cd drupalfreeze

# 4/14. local drupal directory
echo ""
echo "Checking local drupal installation in $2"
if [ -f $LOCALDIR/index.php ]; then
  echo "- $LOCALDIR/index.php found"
else
  echo "- Error: $LOCALDIR/index.php not found"
  exit 1
fi

echo ""

if `grep -q "drupal" $LOCALDIR/index.php`; then
  echo "- Local drupal installation found"
else
  echo "- Error: 'drupal' not found in $LOCALDIR/index.php" 
  exit 1
fi

echo ""

# 5/14. Read drupal settings
if [ ! -f $SETTINGS ]; then
  echo "- Error: $SETTINGS not found"
  exit 1
fi

echo ""

# 6/14. Test domain
echo "Downloading index site for testing..."
if `wget $1 -q -O index.html`; then
  echo "- Download successful"
  rm index.html
else
  echo "Error: could not download from $1"
  exit 1
fi

echo ""

# 7/14. Make database backup
DBTOKENS=$( grep "^[$]db_url" $LOCALDIR/sites/default/settings.php | sed "s/[\/,:,@,\']/ /g" )
MYSQL_USER=$( echo $DBTOKENS | awk '{print $4}' )
MYSQL_PASS=$( echo $DBTOKENS | awk '{print $5}' )
MYSQL_DB=$( echo $DBTOKENS | awk '{print $7}' )

# Checking for $db_prefix 
DBTOKENS1=$( grep "^[$]db_prefix" $LOCALDIR/sites/default/settings.php | sed "s/[=,\',\';]/ /g" )
TABLE_PREFIX=$( echo $DBTOKENS1 | awk '{print $2}' )

echo "Creating database backup..."
mysqldump -u $MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB > BACKUP-DB-$DOMAIN_CLEAN.sql
echo "- Database backed up into $WORKDIR/drupalfreeze/BACKUP-DB-$DOMAIN_CLEAN.sql"
echo ""

# 8/14. Updating drupal DDBB
echo "Disabling several modules and dynamic features..."
mysql -u $MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB -e"UPDATE ${TABLE_PREFIX}node SET comment=1;"
mysql -u $MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB -e"UPDATE ${TABLE_PREFIX}system SET status=0 WHERE name='search';"
mysql -u $MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB -e"UPDATE ${TABLE_PREFIX}blocks set status=0 WHERE module='user';"
echo ""

# 9/14. Create a tar file
echo "Creating backup of the code..."
tar -czf BACKUP-CODE-$DOMAIN_CLEAN.tar.gz $LOCALDIR 2>/dev/null
echo "Done..."
echo ""

# 10/14. Mirroing drupal site
echo "Mirroring website from $DOMAIN..."
httrack $DOMAIN -w -O STATIC-$DOMAIN_CLEAN -q -Q -u0 -d --robots=0 >/dev/null
echo ""
echo "Site mirroed"
echo ""

# 11/14. Hidding the rest of webforms
echo "Hiding all web forms..."
for i in $(find $WORKDIR/drupalfreeze/STATIC-$DOMAIN_CLEAN -type f -iname "*.css"); do echo 'form {display:none;}' >> $i ; done
echo ""

# 12/14. Moving originl drupal code
echo "Moving '$LOCALDIR' to /tmp..."
cp -a $LOCALDIR $WORKDIR
rm -rf $LOCALDIR
echo ""

# 13/14. Redirecing old drupal pages to the new static ones via htaccess
echo "Adding htaccess for redirecting old drupal URLs to the new HTML pages..."
echo 'RewriteEngine On
RewriteBase /
RewriteRule (.*)html.html$ - [PT,L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*image.*)$ $1 [L]
RewriteRule ^(.*node.*)$ $1%0html.html [R,L]
' > STATIC-$DOMAIN_CLEAN/$DOMAIN_CLEAN/.htaccess
echo ""

# 14/14. Moving static site to the old drupal site directpry
echo "Moving the static site $WORKDIR/drupalfreeze/STATIC-$DOMAIN_CLEAN/$DOMAIN_CLEAN $LOCALDIR to $DOMAIN"
cp -r $WORKDIR/drupalfreeze/STATIC-$DOMAIN_CLEAN/$DOMAIN_CLEAN $LOCALDIR
rm -rf $WORKDIR/drupalfreeze/STATIC-$DOMAIN_CLEAN/$DOMAIN_CLEAN

echo "Done!"
echo ""
echo "Visit & check: $1"
echo ""
echo ""

exit 0

