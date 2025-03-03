# DOC_ROOT must be defined correctly. This is the full path working directory 
# to the file index.rb is in (without specifying index.rb and with no trailing slash).
#
# The install script will automatically put what it thinks the appropriate 
# doc root is at the top of this file. If this is incorrect, change it to reflect 
# your actual doc root location. 
# If you are NOT using the install script, an example is shown below - uncomment
# and change
# DOC_ROOT = "/path/to/webroot"

DOWNCASE_BASE_URL = true 
# For most sites, you want the above set to true. This means the user-requested 
# URL is downcased before comparisons, which you generally want. 
# Query params are intentionally still case-sensitive, which you would want, 
# even when variable is set to true.

# in a starting setup, you should have nothing in these folders: db, scripts, 
# public_auto_urls, assets, component_fns, forms and templates
# Those are for YOU to fill as you need

# when troubleshooting, look at apache error log for ruby errors
# at /var/log/apache2/error.log


ERROR_404 = "routed/default-404.rb"
ERROR_TOKEN_MISMATCH_403 = "routed/default-token-mismatch-403.rb"
#ONLY_ALLOWED_AS_POST = ["/final-page", "/submit"] # urls which are disallowed with any method other than POST - typically form processing pages
ONLY_ALLOWED_AS_POST = []
UNPUBLISHED = []

# cookie setting for development sites or those without https
COOKIE_DEFAULTS = "SameSite=Strict"
# If you are making a production site, comment out the above line and uncommet
# the one below. Note that if you do not have https on your production site, 
# the settings below will not be appropriate and will likely result in an 
# automatic 403 mismatch due to cookies not being able to be set properly
# BELOW: cookie setting for production sites with https
# COOKIE_DEFAULTS = "Secure; SameSite=Strict"

# more cookie settings - defaults suitable for development and production sites
ENCRYPT_COOKIES = true # the cookie values themselves are encrypted - does not require https
SANITIZE_DEFAULT = Sanitize::Config::RESTRICTED # less strict alternatives to RESTRICTED are RELAXED or BASIC
# currently there is purposely no way to NOT sanitize cookie values upon retrieval, for security reasons
# if there is demand this is something that could be changed later

# session settings are in sess-file-vars.rb

# csrf protection settings
ENABLE_CSRF_PROTECT = true # for security reasons this should always be set to true
CSRF_SKIP = [] # urls for which we want to skip csrf checks. This may be the route with the form AND/OR that with the submitted form
CSRF_TOKEN_NAME = "csrftoken" # token name used in file session storage (NOT in forms)
CSRF_TOKEN_NAME_FORMS = "RandomToken" # default token name used in forms

# next section only if using a database, otherwise don't need
### start database config ###
#require 'sequel' 
#require 'sqlite3'
#require 'date'
#DB = Sequel.sqlite('/home/newuser/zurfbirb_for_apache/user_comments.db')
# the above connection format for sqlite database with the Sequel ORM means the database 
# will be created if it doesn't already exist, which is why it's good for beginners.
# You are free to use any type of database and any type of compatible ORM you wish
# e.g. use ActiveRecord and Postgresql if you prefer. It's up to you! 
### end database config ###

#### ROUTES - define as follows #####

### Start non-template routes - e.g. static pages ###
# You'll want to change the route for "/" to your homepage rb file - this may be 
# as a template page, but does not have to be. The default is to show a test page
$relate_root = {"/" => "routed/default_homepage.rb"}
### end non-template routes ###

### Start template routes (optional) ###
# map urls to page variables to templates instead of making a giant array of 
# hashes in one go, this breaks it up to make it a bit more readable
## static pages and template ##
#ps1 = {:url => "/about-us", :locals => {:title_str => "About us", :body_html => in_file("about-us.html")}}
#ps2 = {:url => "/privacy-policy", :locals => {:title_str => "Privacy policy", :body_html => in_file("privacy-policy.html")}}
#article = {:template_fn => :article_page, :pages => [ps1, ps2]}
## gallery pages and template ##
#gp1 = {:url => "/photos", :locals => {:title_str => "Recent photos"}}
#gp2 = {:url => "/meet-the-team", :locals => {:title_str => "Photos of our team"}}
#gallery = {:template_fn => :gallery, :pages => [gp1, gp2]}
## more result pages and templates ##
### ... ###
## finally, list of all templates ##
#$template_map = [article]
### End template routes ###
#### END ROUTES #####


## only change below if you know what you're doing ##
req_all_in_dir(COMPONENT_DIR)
req_all_in_dir(TEMPLATE_DIR)
req_all_in_dir(FORM_DIR)

# do not require all in form or script dirs if you 
# are working with html forms or js scripts
# Only require form dir contents if they are specified as ruby methods

