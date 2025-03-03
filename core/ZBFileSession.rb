# User vars may only be stored as strings in ZBFileSession, not as
# objects. Thus no serializer or deserializer is used. 
# It is not the job of ZBFileSession to sanitize data being stored
# it is assumed that you have sanitized any untrusted data prior to
# being stored via ZBFileSession. If there is demand, the option to 
# sanitize could be added (e.g. via sanitize gem), but the 
# question becomes what level of sanitization do you want, and could 
# it possibly affect any *trusted* data being stored. i.e. it is a 
# blunt instrument.

class ZBFileSession
	
	require 'tempfile'
	require 'fileutils'
	require 'securerandom'
	require 'openssl' # encryption uses openssl
	require 'base64' # base64 converts encrypted to text instead of binary
	require 'date'
	require_relative 'ZBcookies.rb'
	include ZBcookies	
	
	# general variables
	@@default_sess_filename = $zb_sess_filename || "zb-s-def.txt"
	@@default_sess_dir = $zb_sess_dirname || "/tmp/zurfbirb-def"
	@@delim_var = $zb_delim_var || "\t" # avoid base64 chars
	@@delim_keys = $zb_delim_keys || "|" # avoid base64 chars
	@@delim_keyval = $zb_delim_keyval || "^^" # avoid base64 chars
	@@sess_expiry_time = $zb_sess_expiry_time || 900
	@@sess_id_gen = $zb_sess_id_format || :uuid
	
	# encryption variables
	@@full_path_to_keyfile = $zb_sess_crypt_key_file || "/tmp/zbk/keyfile.key" 
	# keyfile is for encrypting and decrypting the session info
	# It contains the symmetric key.
	# The keyfile default abiove is NOT a secure location - you want to specify a 
	# file that is OUTSIDE your web app tree and NOT in a /tmp subfolder.  
	# A goodexample would be /home/yourusername/for_apache/keyfile.key The key file need not
	# already exist - if not, it and the key will automatically be 
	# generated for you - however, you need to ensure that the location has the correct 
	# permissions for the Apache user, typically www-data , to read and write 
	# this file (without being world readable and writeable). Check documentation for 
	# full details if unsure how to do this.
	# To rotate keys, simply delete the keyfile AND then immediately delete 
	# the session file (since new keys can't decrypt existing sessions).
	# New files will automatically be generated
	# Note that existing sessions will be deleted when rotating keys
	# this way
	
	attr_accessor :timestamp, :sess_id, :user_vars, :expires
	
	def initialize(id_name = "", expires = @@sess_expiry_time, autowrite = true)
		# if id_name not specified, an ID will be generated
		# default expiry is given in seconds after the session is initialized
		# defaults to 900 ( = 15 minutes )
		now = Time.now
		@sess_id = gen_sess_id(id_name, @@sess_id_gen)
		@timestamp = now.to_i # Unix timestamp
		@expires = now.to_i + expires # in Unix timestamp format
		@user_vars = ""
		if autowrite
			write_sess_to_file(@@default_sess_filename, @@default_sess_dir, ZBFileSession.encrypt_file_data?)
		end
	end
	
	def self.encrypt_file_data?
		# by default, this value is true. It is only false if we 
		# have a defined constant called ZB_ENCRYPT_FILE_SESS and
		# it is set to false.
		# If encrypt_file_data? returns true, this means data stored in the
		# file will be encrypted as it is stored in the file
		# and decrypted when it is read into memory
		if defined?(ZB_ENCRYPT_FILE_SESS) and (ZB_ENCRYPT_FILE_SESS == false)
			false
		else
			true
		end
	end
	
	def self.keyfile_exist?
		File.exist?(@@full_path_to_keyfile)
	end
	
	def self.create_keyfile
		unless ZBFileSession.keyfile_exist?
			# create key
			tempcipher = OpenSSL::Cipher::AES.new(128, :OFB).encrypt
			key = tempcipher.random_key
			b64key = Base64.strict_encode64(key)
  	        FileUtils.mkdir_p(File.dirname(@@full_path_to_keyfile))
			out_file = File.new(@@full_path_to_keyfile, "w", 0600)
			out_file.write(b64key)
			out_file.close
		end
	end
	
	def self.get_key
		# returns the stored key in keyfile in binary format
		# ready to use in cipher straight away
		
		# first make sure there is a keyfile
		unless ZBFileSession.keyfile_exist?
			ZBFileSession.create_keyfile
		end
		# get key and convert to encoded format
		infile = File.open(@@full_path_to_keyfile, "r") 
		b64line = infile.read
		infile.close
		Base64.decode64(b64line)
	end
	
	def self.encrypt(str)
		# given a plaintext string, returns a string which 
		# contains the AES-128-OFB encrypted string converted from binary
		# to base 64, then prepended by the plaintext 
		# IV (initial value) used in the encryption. The IV needs to be
		# different for each encryption. For this cipher, the IV must be
		# 16 bytes in length = SecureRandom.hex(8)
    	# if an empty string is passed, nothing is encrypted and
    	# an empty string is returned
    	if str == ""
        	""
        else
        	clear_iv = SecureRandom.hex(8)
        	cipher = OpenSSL::Cipher::AES.new(128, :OFB)
        	cipher.encrypt
        	cipher.key = ZBFileSession.get_key
        	cipher.iv = clear_iv
        	encr_portion_bin = cipher.update(str) + cipher.final
        	encr_portion_64 = Base64.strict_encode64(encr_portion_bin)
        	clear_iv + encr_portion_64
        end
	end
	
	def self.decrypt(str)
		# the exact inverse of self.encrypt
		# Given a base64 encoded version of an encrypted binary string
		# that is prepended by a 16-byte (8 char hexadecimal) plaintext IV, 
		# (i.e. the direct output of self.encrypt), decrypts
		# it according to the AES-128-OFB algorithm using a stored
		# key. If an empty string is given, no decryption takes place and an 
		# empty string is returned. If unable to decrypt, returns false
		if str == ""
			""
		else
			clear_iv = str.dup.byteslice(0, 16)
			removed = str.slice!(clear_iv)
			# at this point, str is now the remainder after clear_iv is removed
			# str represents the base64-encoded version of the encrypted string
			str_bin = Base64.decode64(str)
			cipher = OpenSSL::Cipher::AES.new(128, :OFB)
			cipher.decrypt
			cipher.key = ZBFileSession.get_key
			cipher.iv = clear_iv
			cipher.update(str_bin) + cipher.final
		end
	rescue
		STDERR.puts "Exception in ZBFileSession.decrypt - unable to decrypt"
		# Some possible causes of this error: 
		# 1. Attempting to decrypt an empty string or something else which was not encrypted
		# 2. If you recently switched from unencrypted to encrypted sessions.
		# In this situation consider deleting the session file (a new one will automatically
		# be generated) although this means currently active session data will be lost.
		# 3. The data you are trying to decrypt has been tampered with
		# 4. There has been an update to the way OpenSSL::Cipher or Base64 works
		# which has not been changed in ZBFileSession - open an issue on GitHub
		return false
	end
	
	def sessline_2_obj(line)
		line_arr = line.split(@@delim_var)
    	if line_arr[3] == "\n"
    		# if user vars are not present, that section of line_arr will be the newline character
    		uvars = false
        else
        	uvars = true
        end
		if ZBFileSession.encrypt_file_data?
			@sess_id = ZBFileSession.decrypt(line_arr[0])
			@timestamp = ZBFileSession.decrypt(line_arr[1]).to_i
			@expires = ZBFileSession.decrypt(line_arr[2]).to_i
        	if uvars
        		@user_vars = ZBFileSession.decrypt(line_arr[3])
            else
            	@user_vars = ""
            end
		else
			@sess_id = line_arr[0]
			@timestamp = line_arr[1].to_i
			@expires = line_arr[2].to_i
        	if uvars
        		@user_vars = line_arr[3]
            else
            	@user_vars = ""
            end
		end
	end
	
	def self.get_session(id, sess_filename = @@default_sess_filename, sess_location = @@default_sess_dir, encrypt = ZBFileSession.encrypt_file_data?, mode = :load)
		# looks in session file for session with specified id. If found, 
		# and if mode is the default of :load
		# creates a new object of ZBFileSession with the session data of 
		# that ID. 
		# if found and mode is :exist (or anything other than load)
		# then returns true
		# If not found, returns false (this includes if file does not exist)
		fname = sess_location + "/" + sess_filename
		found = false
		result = false
		if File.exist?(fname)
			File.open(fname, "r") {|infile|
				File.foreach(infile) {|line|
					line_arr = line.split(@@delim_var)
					if encrypt
						line_start = ZBFileSession.decrypt(line_arr[0])
						expiry_time = ZBFileSession.decrypt(line_arr[2])
					else
						line_start = line_arr[0]
						expiry_time = line_arr[2]
					end
					if line_start == id
						found = true
						result = ZBFileSession.new(line_start, expiry_time.to_i, false)
						result.sessline_2_obj(line)
					end
				}
			}
			if found == true
				if mode == :load
					return result
				else
					# mode is :find
					return true
				end
			else
				# id not present in file
				return false
			end
		else
			# file does not exist
			return false
		end
	end
	
	def self.sess_id_exist?(id, sess_filename = @@default_sess_filename, sess_location = @@default_sess_dir, encrypt = ZBFileSession.encrypt_file_data?)
		get_session(id, sess_filename, sess_location, ZBFileSession.encrypt_file_data?, :exist)
	end
	
	
	def var_exist?(key)
		user_var_key_reg = /(^#{Regexp.escape(key)}|#{Regexp.escape(@@delim_keys)}#{Regexp.escape(key)})#{Regexp.escape(@@delim_keyval)}/
		@user_vars.match?(user_var_key_reg)
	end
	
	def get_one_var(key)
		if var_exist?(key)
			value_capture = /(^#{Regexp.escape(key)}|#{Regexp.escape(@@delim_keys)}#{Regexp.escape(key)})#{Regexp.escape(@@delim_keyval)}(?<value>.*?)#{Regexp.escape(@@delim_keys)}/
			mdata = @user_vars.match(value_capture)
			mdata[:value]
		else
			false
		end
	end
	
	def empty?
		(@sess_id == nil) and (@timestamp == nil) and (@expires == nil) and (@user_vars == "")
	end
	
	def update_one_var(key, value)
		if var_exist?(key)
			# need to update an existing value
			prev_val = get_one_var(key)
			section_to_replace = /#{Regexp.escape(key)}#{Regexp.escape(@@delim_keyval)}#{Regexp.escape(prev_val)}#{Regexp.escape(@@delim_keys)}/
			new_section = key + @@delim_keyval + value.to_s + @@delim_keys
			@user_vars.sub!(section_to_replace, new_section)
		else
			# var does not already exist - append it to user vars
			@user_vars << key.to_s << @@delim_keyval << value.to_s << @@delim_keys
		end
		write_sess_to_file(@@default_sess_filename, @@default_sess_dir, ZBFileSession.encrypt_file_data?)
	end
	
	def update_many_vars(keyval_hash)
		if keyval_hash.class == Hash
			keyval_hash.each_pair {|key, val| update_one_var(key, val)}
			true
		else
			false
		end
	end
	
	def get_expiry_time
		# expiry (and timestamp) are expressed as integers
		# but written to file as string
		@expires.to_i
	end
	
	def update_expiry_time(new_expiry)
		@expires = new_expiry.to_i
		write_sess_to_file(@@default_sess_filename, @@default_sess_dir, ZBFileSession.encrypt_file_data?)
	end
	
	def delete
		write_sess_to_file(@@default_sess_filename, @@default_sess_dir, ZBFileSession.encrypt_file_data?, :delete)
		@sess_id = nil
		@timestamp = nil
		@expires = nil
		@user_vars = ""
	end
	
	def write_sess_to_file(sess_filename = @@default_sess_filename, sess_location = @@default_sess_dir, encrypt = true, mode = :add)
		# valid modes are :add or :delete
		# as currently implemented, anything other than the default :add
		# will result in delete behavior
		unless empty?
			# only handle non-empty objects for file ops
			unless File.exist?(sess_location)
				FileUtils.mkdir_p(sess_location)
			end
			delim = @@delim_var
			#	name = sess_filename ... not used
			fname = sess_location + "/" + sess_filename
			tempfile_base_name = "zurfbirb-tmp-sess"
			if encrypt
				line_format = ZBFileSession.encrypt(@sess_id) + delim + ZBFileSession.encrypt(@timestamp.to_s) + delim + ZBFileSession.encrypt(@expires.to_s) + delim + ZBFileSession.encrypt(@user_vars.to_s) + "\n"
            else
				line_format = @sess_id + delim + @timestamp.to_s + delim + @expires.to_s + delim + @user_vars.to_s + "\n"
			end
			written = false
			if File.exist?(fname)
				# session file already exists - need to modify
				temp_file = Tempfile.new(tempfile_base_name)
				File.open(fname, "r") {|infile|
					File.foreach(infile) {|line|
						# check each line if current sess id
						line_arr = line.split(delim)
						if encrypt
							line_start = ZBFileSession.decrypt(line_arr[0])
						else
							line_start = line_arr[0]
						end
						if line_start == @sess_id
							# if in add mode
							# update the entry for this session id
							if mode == :add
								# add the line
								temp_file.write(line_format)
								written = true
							end
							# do nothing in other modes, including delete
						else
							# copy over non-matching session id line
							# but only if it's not expired
							if encrypt
								expiry_time = ZBFileSession.decrypt(line_arr[2])
                            	# this value may return false or empty
                            	# will ignore lines we can't decrypt (e.g. due to key rotation)
							else
								expiry_time = line_arr[2].to_i
							end
							if (expiry_time != false) and (expiry_time != "") and (expiry_time.to_i > Time.now.to_i)
								temp_file.write line
							end
						end
				}	}
				if (written == false) and (mode == :add)
					# if not already written,  and if mode is add
					# need to add current sess
					temp_file.write(line_format)
				end
				temp_file.close
				FileUtils.mv(temp_file.path, fname)
				temp_file.close
				temp_file.unlink
			else
				# session file does not already exist
				# if in add mode, need to create and add sess
				if mode == :add
					out_file = File.new(fname, "w", 0600)
					out_file.write(line_format)
					out_file.close
				end
			end
		end
	end
	
	def plaintext_write_sess_to_file(sess_filename = @@default_sess_filename, sess_location = @@default_sess_dir)
		write_sess_to_file(sess_filename = @@default_sess_filename, sess_location = @@default_sess_dir, false)
	end
	
	def gen_sess_id(id_name = "", format = :uuid)
		if id_name == ""
			case format
			when :uuid
				SecureRandom.uuid
			when :hex27
				SecureRandom.hex(27)
			when :hex40
				SecureRandom.hex(40)
			else
				# if something unknown is specified, fall back to uuid
				SecureRandom.uuid
			end
		else
			# id was specified in params
			id_name
		end
	end
	
end
