#!/usr/bin/ruby
puts ("Content-type:text/html; charset=UTF-8")
puts("referrer-policy: origin-when-cross-origin")
puts("x-frame-options: SAMEORIGIN")
puts("x-xss-protection: 1; mode=block")
puts("x-content-type-options: nosniff")
# feel free to change the headers above to whatever you want

# you should specify your routes (and optionally your database) in config/config.rb

# don't need to change anything on this page you know what you are doing 
## start getting settings and core functions ##
# if you change anything, please note the order of these statements is important 
# in terms of dependencies 
COMPONENT_DIR = "component_fns" 
TEMPLATE_DIR = "templates" 
AUTO_URL_DIR = "public_auto_urls"
SCRIPT_DIR = "scripts" 
FORM_DIR = "forms"
HTML_DIR = "html"
CGI_FN_DIR = "core"
CONFIG_DIR = "config"

$dir_lookup_arr = [COMPONENT_DIR, TEMPLATE_DIR, FORM_DIR, SCRIPT_DIR, HTML_DIR, "assets/styles"] # order of lookup locations for files
require_relative CONFIG_DIR.dup.concat('/sess-file-vars.rb')

require_relative CGI_FN_DIR.dup.concat('/html_markup.rb')
require_relative CGI_FN_DIR.dup.concat('/ZBcookies.rb')
require_relative CGI_FN_DIR.dup.concat('/ZBFileSession.rb')
require_relative CGI_FN_DIR.dup.concat('/ZBcsrf.rb')
require_relative CGI_FN_DIR.dup.concat('/core.rb')
require_relative CONFIG_DIR.dup.concat('/config.rb')
## end of getting settings and core functions ###

if DOWNCASE_BASE_URL
	@req_path = ENV['REQUEST_URI'].downcase
else
	@req_path = ENV['REQUEST_URI']
end

if (defined?(ENV['HTTP_REFERER']) == false) or (ENV['HTTP_REFERER'] == nil)
	@refer = ""
else
	@refer = ENV['HTTP_REFERER']
end

# do named capture via regex for everything up to word boundary
# We expect the url to end with not a dash or a underscore, so alphanumeric only
reg_path_boundary = /(?<plain_req>(^[A-Za-z0-9\-\/\_]+)[A-Za-z0-9]\b)/
if reg_path_boundary.match?(@req_path)
	@plain_path = reg_path_boundary.match(@req_path)[:plain_req]
else
	@plain_path = @req_path
end

@plain_path.squeeze!("/")

# directories that we don't want examined
$disallowed_dirs = [COMPONENT_DIR, TEMPLATE_DIR, FORM_DIR, SCRIPT_DIR, HTML_DIR]

if (defined?$template_map)
	inspect_template_map = req_path_in_templates(@plain_path, $template_map)
end

@post_params = ""
@form_params = Hash.new
continue = true

if ENV['REQUEST_METHOD'] == "POST"
	@unsafe_post_params = gets.force_encoding("utf-8")
	@post_params = Sanitize.fragment(@unsafe_post_params, SANITIZE_DEFAULT)
	@form_params = get_form_pars(@unsafe_post_params, true)
	# check params for CSRF protection
	if csrf_protect_page?
		if csrf_token_match? == false
			puts("Status: 403 Forbidden\n\n")
			load(ERROR_TOKEN_MISMATCH_403)
			continue = false
		end
	end # if csrf
end # if request method post

if (ENV['REQUEST_METHOD'] != "POST") and (ONLY_ALLOWED_AS_POST.any?{|disallowed|@plain_path == disallowed})
	# disallow pages defined as POST-only if called with GET or any method other than POST
	puts("Status: 403 Forbidden\n\n")
	load(ERROR_TOKEN_MISMATCH_403)
	continue = false
end

if continue
	# we now pass the request to the appropriate page
	# first check for invalid requests - for example plain_path starting ///
	reg_allow_start = /^\/[A-Za-z0-9]/
	reg_allow_homepage = /^\/$/
	if (reg_allow_start.match?(@plain_path) == false) and (reg_allow_homepage.match?(@plain_path) == false)
		puts("Status: 404 Not Found")
		#make sure we print at least 1 blank line after headers
		puts("\n\n")	
		load(ERROR_404)
		# next make sure disallowed directories aren't being accessed
	elsif $disallowed_dirs.any? {|onedir| @plain_path.start_with?(onedir.dup.prepend("/"))}
		# sinkhole requests that reflect requests or directories that we don't want displayed
		puts("Status: 404 Not Found")
		#make sure we print at least 1 blank line after headers!
		puts("\n\n")	
		load(ERROR_404)
	elsif UNPUBLISHED.any?{|disallowed|@plain_path == disallowed}
		puts("Status: 404 Not Found")
		#make sure we print at least 1 blank line after headers!
		puts("\n\n")	
		load(ERROR_404)
	elsif defined?($relate_root) and ($relate_root.has_key?(@plain_path))
		# priority in validly formatted URL is matching explicit user-defined non-template routes in $relate_root
		#make sure we print at least 1 blank line after headers!
		puts("\n\n")	
		load($relate_root[@plain_path])
	elsif (defined?($template_map)) and (inspect_template_map[:found] == true)
		# second priority is matching template routes
		#make sure we print at least 1 blank line after headers!
		puts("\n\n")
		self.method(inspect_template_map[:template_fn]).call(**inspect_template_map[:locals])
	elsif defined?(AUTO_URL_DIR) and (rb_file_present?(@plain_path, AUTO_URL_DIR))
		# last priority is matching auto-urls
		#make sure we print at least 1 blank line after headers!
		puts("\n\n")
		load(AUTO_URL_DIR.dup.concat("/", @plain_path.dup, ".rb"))
	else
		# if nothing matches, use fall-through of 404 not found
		puts("Status: 404 Not Found")
		#make sure we print at least 1 blank line after headers!
		puts("\n\n")
		load(ERROR_404)
	end
	
end # if continue
