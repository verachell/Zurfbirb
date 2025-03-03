module ZBcookies
	require_relative 'ZBFileSession.rb'
	require_relative 'html_markup.rb'
	require 'sanitize'
	
	def encrypt_cookies?
		if defined?(ENCRYPT_COOKIES) and (ENCRYPT_COOKIES == false)
			false
		else
			true
		end
	end
    
	def set_cookie_js(name, value, cookie_attr = COOKIE_DEFAULTS, encrypt_value = encrypt_cookies?)
		# given a string with a name=value string e.g. "uname=johndoe" and other attributes
		# e.g. "Secure; SameSite=Strict", writes a string of javascript
		# to set that cookie
		# e.g. puts('<script>document.cookie = "uname=johndoe; Secure; SameSite=Strict";</script>')
		# if you don't want any attributes, pass an empty string to cookie_attr
		if encrypt_value
			name_value_str = name + "=" + ZBFileSession.encrypt(value)
		else
			name_value_str = name + "=" + value
		end
		cookie_attr.rstrip.chomp(";")
		result = "<script>document.cookie = \"" + name_value_str.chomp(";") + "; " + cookie_attr.chomp(";")+ "\";</script>"
		puts result
	end
	
	def get_cookies_header
		# This method is NOT intended to be called by the user except for debugging purposes. Instead
		# call cookie_value, cookie_exist?, or get_cookie_hash, all of which decrypt if needed and 
		# sanitize. 
		# This method does not decrypt nor sanitize. 
		# Retrieves name-value pairs as a semi-colon separated string e.g. "username=johndoe; wallpaper=Red" 
		# Note that this method only retrieves cookies via the header, not via javascript. Therefore,
		# if you set a javascript cookie on current page, this method won't see it unless you reload current page
		# or load a different page as headers need to be passed for this method to work. If this is too restrictive 
		# for your application, which is likely, consider using your own custom javascript in a file that you 
		# place in the scripts directory of your application. You can then include your script 
		# in your html doc via: puts in_file("myscript.js")
		ENV['HTTP_COOKIE']
	end
	
	def get_cookie_arr
		# This method is NOT intended to be called by the user except for debugging purposes. Instead
		# call cookie_value, cookie_exist?, or get_cookie_hash, all of which decrypt if needed and 
		# sanitize,
		# This method does not decrypt nor sanitize, and extra whitespace may be present
		cookie_str = get_cookies_header
		if (cookie_str == "") or (cookie_str == false) or (cookie_str == nil)
			Array.new
		else
			get_cookies_header.split(";")
		end
	end
	
	def get_cookie_hash(encrypted_values = encrypt_cookies?, sanitize_cookies = true)
		# never do split method on = sign for cookies - we may have b64-encoded stuff that contains it
		# instead use index for where to split
		arr = get_cookie_arr
		result = Hash.new
		if arr.empty?
			result
		else
			arr.each{|name_val_str|
				len = name_val_str.length
				split_ind = name_val_str.index("=")
				if split_ind != nil
					# we have a name value pair
					name = name_val_str[0..(split_ind - 1)].strip
					raw_value = name_val_str[(split_ind + 1)..(len - 1)].strip
					if encrypted_values
						decrypted = ZBFileSession.decrypt(raw_value) || "" # if decrypt returns false, return empty string
					else
						decrypted = raw_value
					end
					if sanitize_cookies
						if defined?(SANITIZE_DEFAULT)
							value = Sanitize.fragment(decrypted, SANITIZE_DEFAULT)
						else
							value = value = Sanitize.fragment(decrypted)
						end
					else
						value = decrypted
					end
					result[name] = value
				end
				# do nothing if we don't have a name value pair, move onto next one
			}
			result
		end
	end
	
	def cookie_exist?(cookie_name)
		cookie_hash = get_cookie_hash
		cookie_hash.has_key?(cookie_name)
	end
	
	def cookie_value(cookie_name)
		# if cookie name exists, returns its value
		# if it does not exist, returns false
		if cookie_exist?(cookie_name)
			get_cookie_hash[cookie_name]
		else
			false
		end
	end
	
	def unencrypted_cookie_exist?(cookie_name)
		# useful if you set unencrypted cookies via javascript, to retrieve them
		# Only use unencrypted cookies for things that you want to be publicly viewable
		cookie_hash = get_cookie_hash(false)
		cookie_hash.has_key?(cookie_name)
	end
	
	def unencrypted_cookie_value(cookie_name)
		# useful if you set unencrypted cookies via javascript, to retrieve them
		# Only use unencrypted cookies for things that you want to be publicly viewable
		# if cookie name exists, returns its value
		# if it does not exist, returns false
		if unencrypted_cookie_exist?(cookie_name)
			get_cookie_hash(false)[cookie_name]
		else
			false
		end
	end
	
end # end ZBcookies
