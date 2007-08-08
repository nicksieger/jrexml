JREXML is an add-on for JRuby that uses a Java pull parser library to speed up REXML.

REXML is, unfortunately, painfully slow running under JRuby at the moment due to the slowness of regular expression parsing. JREXML shoves a small wrapper around XPP3/MXP1 (http://www.extreme.indiana.edu/xgws/xsoap/xpp/mxp1/) into the guts of REXML, disabling the regular expression parser and providing close to a 10x speedup.

= Install

Simply install the gem under JRuby:

    jruby -S gem install jrexml

And require 'jrexml' to speed up REXML.

    gem 'jrexml'
    require 'jrexml'

= License

This software is released under an MIT license.  For details, see the LICENSE.txt file included with the distribution.  The software is copyright (c) 2007 Nick Sieger <nicksieger@gmail.com>.

This product includes software developed by the Indiana University Extreme! Lab (http://www.extreme.indiana.edu/).  See the license in the file lib/xpp3.LICENSE.txt for details.