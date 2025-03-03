doctype_html
open_head
title("Default landing page")
link(:rel => "stylesheet", :type => "text/css", :href => "/assets/styles/out.css")
close_head
open_body
h1("Hello World - this page generated with Ruby", :style =>"color:red")
pg("This is the default Ruby-generated page")
pg("You'll likely want to change the route of this page in your config.rb file so it points to YOUR home page .rb file instead of this .rb file", :class => "bg-yellow-500")
hr
pg(em_v("Default homepage provided by Zurfbirb"))
close_body