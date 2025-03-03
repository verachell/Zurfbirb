module HTMLmarkup
	
	def doctype_html
		puts "<!DOCTYPE html>"
	end
	
	def html_element(*strs)
		# given an arbitrary amount of strings, and optional 
		# keyword arguments (explained here), returns tagged html output 
		# of the concatenated strings. Remember, argument call order is all strings
		# then all keywords. Keys may be in string or symbol format as desired - EXCEPT for 
		# the :tag , :valonly or :openonly keywords, which MUST be in symbol format.
		# By default, the value is returned as 
		# a puts statment, although this depends on one of the keyword arguments.
		# Keyword args: the :tag is the html tag without the <> e.g. :h1 or "h1"
		# if tag: is not given, it is assumed to be a <p> tag. 
		# If called with :openonly => true, it will return only an opening tag without
		# a closing tag. Useful for <div>, <footer> and other tags which might have 
		# a lot more content in between before closing.
		# If called with  :valonly => true, the 
		# resultant string is not printed but simply returned as a string. Any html
		# attributes desired to be added should be used as keyword arguments
		# for example, if you want style="max-width:100%" and class="banana" then
		# you would call with :style => "max-width:100%", :class => "banana"
		#
		# example use case call illustrating nested html elements:
		# html_element("the title of this ", html_element("great", :valonly => true, :tag => :strong, :style => "text-color:red", :class => "cd-54 pw xb"), " article", :tag => :h1, :style => "background-color: blue")
		# returns
		# <h1 style="background-color: blue">the title of this <strong style="text-color:red" class="cd-54 pw xb">great</strong> article</h1>
		# note in the above example you'd want to make sure nested elements have :valonly => true 
		#
		# NOTE: you won't usually be calling this function directly in your CGI programming
		# Instead, for commonly used elements, convenient variants are defined further down this page
		# meaning you can do h2("A great subheading!", :style => "color:magenta")
		# value-only variants are also pre-defined later on this page for the most commonly-nested elements
		# these are suffixed with _v for example, you can call span_str = span_v("this text is red!", :style => "color:red")
		# more commonly, you'd use it to nest _v elements directly 
		# in another element for example to rewrite the first h1 example from above:
		# h1("the title of this", strong_v("great", :style => "text-color:red", :class => "cd-54 pw xb"), " article", :style => "background-color: blue")
		void_tags = ["br", "img", "hr", "col", "area", "embed", "input", "meta", "source", "wbr", "track", "link"]
		val_only = false
		open_only = false
		if strs.last.class == Hash
			kw_args = strs.pop
		else
			kw_args = Hash.new
		end
		if kw_args.include?(:tag)
			html_tag = kw_args[:tag].to_s
			kw_args.delete(:tag)
		else
			# or should this instead be tagless if unspecified?
			html_tag = "p"
		end
		if kw_args.include?(:valonly)
			if kw_args[:valonly] == true
				val_only = true
			end
			kw_args.delete(:valonly)
		end
		if kw_args.include?(:openonly)
			if kw_args[:openonly] == true
				open_only = true
			end
			kw_args.delete(:openonly)
		end
		result = String.new.concat("<", html_tag)
		if kw_args.empty? == false
			# need to add attributes
			kw_args.each_pair{|key, value| result.concat(" ", key.to_s, "=\"", value.to_s, "\"")}
		end
		if void_tags.include?(html_tag.downcase) == false 
			result.concat(">")
			# return result from here for single open tag
			if open_only == true
				if val_only == true
					return result
				else
					puts result
					return
				end
			end
		else
			result.concat(" ")
		end
		# now add string args, if any
		if strs.empty? == false
			strs.each{|str| 
			result << str}
		end
		if void_tags.include?(html_tag.downcase) == true
			result << ">"
		else
			result.concat("</", html_tag, ">")
		end
		if val_only == true
			return result
		else
			puts result
		end
	end
	
	def close_tag(tag, valonly: false)
		# given a tag as a symbol or string, e.g. :div or "div"
		# returns the closed version of the tag e.g. </div>
		# also works with variables declared with sp_tag, sp_div, sp_footer etc
		# :valonly => false (default) prints the tag
		# :valonly => true returns it as a variable
		if tag.class == Hash
			# it's a variable declared by one of the open_ functions
			result = tag[:close]
		else
			# the tag has been passed to us in arg as a string or symbol
			result = String.new.concat("</", tag.to_s, ">")
		end
		if valonly == true
			return result
		else
			puts result
		end
	end
	
	def close_footer
		close_tag("footer")
	end
	
	def close_div
		close_tag("div")
	end
	
	def close_article
		close_tag("article")
	end
	
	def close_section
		close_tag("section")
	end
	
	def close_section
		close_tag("aside")
	end
	
	def close_body
		close_tag("body")
	end
	
	def close_head
		close_tag("head")
	end
	
	def close_nav
		close_tag("nav")
	end
	
	def close_table
		close_tag("table")
	end
	
	def close_textarea
    	close_tag("textarea")
    end
	
	# now define helper functions to create popular variants with partial
	# application of arguments
	def add_kw(*args, kw_to_apply)
		# if last of args is a hash, merge with kw_to_apply
		if args.last.class == Hash
			args.last.merge!(kw_to_apply)
		else
			args.push(kw_to_apply)
		end
		return args
	end
	
	def add_tag_and_call_html(*args, kw_to_apply)
		new_args = add_kw(*args, kw_to_apply)
		html_element(*new_args)
	end
	
	# create convenient variants for commonly used html tags
	def pg(*args)
		# paragraph tag
		# note that this one is different from others so as not to collide with 
		# the print statement p in ruby
		add_tag_and_call_html(*args, :tag => "p")
	end
	
	def h1(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def h2(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def h3(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def h4(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def h5(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def h6(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def strong(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def em(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def span(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def img(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def a(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def blockquote(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def br(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def button(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def b(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def article(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def aside(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def body(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def caption(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def code(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def col(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def colgroup(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def div(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def embed(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def fieldset(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def figcaption(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def figure(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def footer(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def form(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def head(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def header(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def hr(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def html(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def input(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def label(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def textarea(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def link(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def main(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def menu(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def meta(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def nav(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def meter(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def ol(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def ul(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def li(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	
	def optgroup(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def option(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def pre(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def s(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def script(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def search(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def section(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def select(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def small(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def style(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def svg(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def table(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def td(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def th(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def tbody(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def tfoot(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def thead(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def tr(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def textarea(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def time(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def title(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	# less commonly used variants
	def area(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def audio(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def canvas(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def dialog(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def hgroup(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def map(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def mark(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def noscript(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def output(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def progress(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def source(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def sub(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def sup(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def track(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def video(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	def wbr(*args)
		add_tag_and_call_html(*args, :tag => __method__.to_s)
	end
	
	# want valonly variants for elements which are commonly nested within others
	# create helper function for this first
	
	def valonly_adder(*args)
		# given user-supplied args, adds the :valonly => true keyword
		# and returns the new args
		add_kw(*args, :valonly => true)
	end
	
	# create valonly variants of commonly nested elements
	
	def em_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "em")
	end
	
	def strong_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "strong")
	end
	
	def button_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "button")
	end
	
	def b_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "b")
	end
	
	def img_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "img")
	end
	
	def a_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "a")
	end
	
	def span_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "span")
	end
	
	def svg_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "svg")
	end
	
	def small_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "small")
	end
	
	def embed_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "embed")
	end
	
	def s_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "s")
	end
	
	def span_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "span")
	end
	
	def sup_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "sup")
	end
	
	def sub_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "sub")
	end
	
	def time_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "time")
	end
	
	def th_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "th")
	end
	
	def td_v(*args)
		add_tag_and_call_html(*valonly_adder(*args), :tag => "td")
	end
	
	# now define sp_tag variants which store and print commonly used openonly tags
	# start with helper function
	def openonly_adder(*args)
		# given user-supplied args, adds the :valonly => true keyword
		# and returns the new args
		add_kw(*args, :openonly => true)
	end
	
	def open_tag(*args)
		# store AND print an open-only tag for the html element defined by :tag 
		# if :tag is not specified in arguments, it is assumed to be div
		# This tag is printed and also returned as a variable
		# in the form of a hash whose keys are :open and :close and whose values
		# are strings. The strings represent the open and close version of the tag
		# usage: my_tag = open_tag(:class => other, :id => "content")
		# this returns <div class="other" id="content> as a hash in the :open key of 
		# the variable you declared (e.g. my_tag) and prints out the open tag. 
		# It also saves the close version
		# of the same tag </div> in a hash in the variable. To later close the tag,
		# all you need to do is close_tag(my_tag) and it will print </div> (or whatever
		# type of tag you used).
		# popular variants of this function are declared below,
		# for example open_footer which does it with the footer element
		if (args.last.class == Hash) and (args.last.include?(:tag))
			the_tag = args.last[:tag]
		else
			the_tag = "div"
		end
		new_val_args = valonly_adder(*args)
		new_openonly_args = openonly_adder(*new_val_args)
		open_value = add_tag_and_call_html(*new_openonly_args, :tag => the_tag)
		puts open_value
		{:open => open_value, :close => close_tag(the_tag, :valonly => true)}
	end
	
	def open_div(*args)
		open_tag(*add_kw(*args, :tag => "div"))
	end
	
	def open_footer(*args)
		open_tag(*add_kw(*args, :tag => "footer"))
	end
	
	def open_article(*args)
		open_tag(*add_kw(*args, :tag => "article"))
	end
	
	def open_section(*args)
		open_tag(*add_kw(*args, :tag => "section"))
	end
	
	def open_body(*args)
		open_tag(*add_kw(*args, :tag => "body"))
	end
	
	def open_head(*args)
		open_tag(*add_kw(*args, :tag => "head"))
	end
	
	def open_nav(*args)
		open_tag(*add_kw(*args, :tag => "nav"))
	end
	
	def open_ol(*args)
		open_tag(*add_kw(*args, :tag => "ol"))
	end
	
	def open_ul(*args)
		open_tag(*add_kw(*args, :tag => "ul"))
	end
	
	def open_aside(*args)
		open_tag(*add_kw(*args, :tag => "aside"))
	end
	
	def open_table(*args)
		open_tag(*add_kw(*args, :tag => "table"))
	end
	
	def open_textarea_required(*args)
		open_tag(*add_kw(*args, :tag => "textarea required"))
	end
	
end
