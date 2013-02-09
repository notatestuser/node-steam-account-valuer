node-steam-account-valuer
=========================
Calculates the value of a Steam account using the current list prices of games

Usage
-----
    $ npm install -g coffee-script
    $ npm link
    $ ./calculator.coffee kimjongun

Limitations
-----------
Unfortunately the script doesn't know how to follow HTTP redirection when scraping an app's store page. This means the following scenarios aren't currently catered for:

* Apps that have new IDs and are being redirected to a new store page.
* Apps that require age verification to view their store page.

Maybe I'll fix this soon enough.
