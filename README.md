freeze script - README file
===========================

This is the documentation for the freeze.sh script.
PURPOSE: Create an HTML version of a drupal site from the server were the target drupal is. 

It is useful when you don't want to maintain old drupal sites
that are not edited anymore. 
freeze.sh is a way to archive drupal sites.

REQUERIMENTS
------------
 - Tested with drupal-5.23 and 6.19.
 - Tested in 2011 in updated Debian & Ubuntu standard machines.
 - httrack: for mirrowing the site.
 - Write permissions in:
            - [path_to_drupa]/[drupal.domain]
            - [/tmp/] resp. $WORKDIR
  - freeze has been tested from the server were the drupal to freeze is.

CONFIGURATION
-------------

 - Edit freeze.sh to cange the working directory:
  WORKDIR="/home/jaume"

 - Edit freeze.sh to fix the path to drupal settings.php file:
  SETTINGS= $LOCALDIR/sites/default/settings.php

USAGE
-----

 Usage: freeze.sh [domain] [local_path] 

FEATURES
--------

 - The old URLs (like http://[site url]/?q=node/3) will work after freezing the site as . 
   (Using .htaccess RewriteRules)
 - The script does the code & DDBB backUp in your $WORKDIR directory.

FUTURE
------

 - Adapt the freeze script to more web applications: CMS, wikis, etc

CREDITS
-------
 
freeze.sh is a servus.at promoted project 
Copyright (C) 2010, Jaume Nualart & servus.at. Catalunya & Austria. Europe
Licensed under the GNU GPL 3
Authors: Jaume Nualart (jaume AT nualart.cat), Chris Hager (chris AT metachris.org), Kenneth Peiruza (kenneth AT contralaguerra.org & Peda (peda AT servus.at).
Barcelona - Catalonia - UE - December 2010
Contact/Comments: jaume AT nualart.cat


README file - Created 18/03/2011
