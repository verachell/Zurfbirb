module ZBcsrf
	require_relative 'ZBFileSession.rb'
	require 'securerandom'
	include HTMLmarkup
	
	def csrf_protect_page?
		# returns true if csrf protection is desired for this page, false otherwise
		if defined?(ENABLE_CSRF_PROTECT) and (ENABLE_CSRF_PROTECT == false)
			false
			#  elsif defined?(CSRF_SKIP) and (CSRF_SKIP.include?(@plain_path) or ((ENV['REQUEST_METHOD'] == "POST") and CSRF_SKIP.include?(@refer)))
		elsif defined?(CSRF_SKIP) and (CSRF_SKIP.include?(@plain_path) or ((ENV['REQUEST_METHOD'] == "POST") and CSRF_SKIP.any?{|csrf_skip|refer_match_relpath?(@refer, csrf_skip)} ))
			false
		else
			true
		end
	end
	
	def find_sess_cookie_name
		if defined?(SESS_NAME)
			SESS_NAME
		else
			"zb_sid"
		end
	end
	
	def find_csrf_token_name
		if defined?(CSRF_TOKEN_NAME)
			CSRF_TOKEN_NAME
		else
			"csrf_token"
		end
	end
	
	def find_csrf_form_token_name
		if defined?(CSRF_TOKEN_NAME_FORMS)
			CSRF_TOKEN_NAME_FORMS
		else
			"RandomToken"
		end
	end
	
	def client_sess_cookie_exist?
		cookie_exist?(find_sess_cookie_name)
	end
	
	def sess_cookie_value
		if client_sess_cookie_exist?
			cookie_value(find_sess_cookie_name)
		else
			false
		end
	end
	
	def analyze_csrf_token_in_sess_file(mode = :value)
		# mode can be :value or :exist
		sess_id = sess_cookie_value
		if sess_id == false
			# no client session
			false
		else
			# a client session cookie exists but we don't know if same exists in session file
			if ZBFileSession.sess_id_exist?(sess_id)
				# it does exist in session file
				curr_sess = ZBFileSession.get_session(sess_id)
				token_name = find_csrf_token_name
				if mode == :exist
					curr_sess.var_exist?(token_name)
				else
					# assuming mode is :value
					curr_sess.get_one_var(token_name)
				end
			else
				# it does not exist
				false
			end
		end
	end
	
	def csrf_token_in_sess_file?
		analyze_csrf_token_in_sess_file(:exist)
	end
	
	def get_csrf_token_value_from_sess_file
		analyze_csrf_token_in_sess_file(:value)
	end
	
	def generate_csrf_token(size = 20)
		SecureRandom.hex(size)
	end
	
	def ensure_csrf_token_set
		# makes sure csrf token is set and then returns the unencrypted token.
		# First, checks if valid sess cookie exists. If cookie exists AND sess ID file is in file sess storage
		# AND if CSRF token exists in file sess storage returns true. If we have the same situation but
		# without CSRF token existing in the session file, one is generated and set there. Returns 
		# unencrypted csrf token value.
		# If instead no cookie exists on client AND/OR no sess storage for that session id
		# a new session is generated and a new CSRF token is generated. Returns unencrypted CSRF token value.
		# by the end of this method, there will be a) a session cookie on client with encrypted sess id
		# as value. b) a session in file session storage on server containing sess id from previous step
		# c) a session variable containing the CSRF token name and value. The unencrypted CSRF token value 
		# is returned.
		if client_sess_cookie_exist? and ZBFileSession.sess_id_exist?(sess_cookie_value)
			if csrf_token_in_sess_file?
				get_csrf_token_value_from_sess_file
			else
				# generate and set csrf token and place in session file storage
				csrf_value = generate_csrf_token
				curr_sess = ZBFileSession.get_session(sess_cookie_value)
				curr_sess.update_one_var(find_csrf_token_name, csrf_value)
				csrf_value
			end
		else
			# now handle case where sess cookie does not exist and/or session storage does not exist
			# start new session
			csrf_value = generate_csrf_token
			curr_sess = ZBFileSession.new
			curr_sess.update_one_var(find_csrf_token_name, csrf_value)
			set_cookie_js(find_sess_cookie_name, curr_sess.sess_id)
			csrf_value
		end
	end
	
	def csrf_field_for_form_v(name = find_csrf_form_token_name)
		# generates a string containing the text for a hidden form field with unencrypted CSRF token
		# this includes generating the appropriate token for the session and storing it in sess storage if needed
		#  e.g. <input type="hidden" name="RandomToken" value=token_value>
		# instead of using uncencrypted token, should be we be using a digest of the token?
		raw_token_value = ensure_csrf_token_set
		"<input type=\"hidden\" name=\"" + name + "\" value=\"" + raw_token_value + "\">"
	end
	
	def open_form(*args)
		open_tag(*add_kw(*args, :tag => "form"))
		if csrf_protect_page?
			puts csrf_field_for_form_v
		end
	end
	
	def close_form
		close_tag("form")
	end
	
	def csrf_token_match?(submitted_token = @form_params[find_csrf_form_token_name])
		# returns true if submitted form parameters contain a CSRF token which matches
		# that in the session file storage for the session. Otherwise resturns false.
		# It is not this method's responsibility to check whether CSRF check should be done 
		# at all - there is another method for that: csrf_protect_page?
		# Check for presence of token, presence of client sess cookie,
		# sess id and sess csrf 
		# first, if no csrf token in sess file, or no csrf token submitted, return false
		# need to do these checks first, otherwise we can wind up with a false == false check, which
		# would return true, giving a false positive
		if (submitted_token == nil) or (submitted_token.empty?)
			return false
		end
		if csrf_token_in_sess_file? == false
			return false
		end
		get_csrf_token_value_from_sess_file == submitted_token
	end
	
end # end ZBcsrf module