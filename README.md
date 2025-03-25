# Zurfbirb
  
  ![zurfbirb logo](zb_main_logo_125.jpg)


## A simple and fun CGI library for Ruby

Make websites in Ruby that don't use middleware! Easy and fun to use. You can code your sites entirely in Ruby through CGI programming. 

Install locally or on a remote server. Even easier to install on a remote server than installing locally! Ideal for a beginner Rubyist who wants to easily create a website that "just works" on a remote server.

Zurfbirb itself is written in Ruby

#### Use Zurfbirb's pre-defined methods...
```ruby
...
open_head
title("The new thing")
link(:rel => "stylesheet", :type => "text/css", :href => "/assets/styles/out.css")
close_head
open_body
h1("My new Ruby site!", :class =>"text-3xl text-violet-500")
...
```
#### ... and define your own methods (no ERB)...
```ruby
def comment_form
h4("add your comment!")
open_form(:method => "post", :action => "/")
label("Your name or nickname", :for => "nickname")
input(:type => "text", :id => "nickname", :maxlength => "50", :class => "rounded border-2")
...
```
#### ... need to import html? No problem!
menu.html:
```html
<nav>
<div class="bg-gray-600 grid grid-cols-3 gap-2 pt-1 pb-1"> 
<div class="mx-auto rounded-md bg-cyan-200 min-w-30 text-center"><a href="/">Home</a></div> 
...
```
then when you want to display it anywhere, just do: 
`puts in_file("menu.html") `

### Features of Zurfbirb
1. No middleware required, just Apache web server
2. 100% Ruby - no mix of Ruby and ERB. Offers the option of including pure html, javascript, text, from file if desired - you may opt to replace designated areas of files with variable values. 
3. Built in templating system available that you can choose to use, or ignore if not needed
4. Use of partials - you can define sections of code that can be re-used anywhere in your site
5. You do not have to use the database if you do not wish to
6. Compatible with Tailwind (see example in tutorial), or use your own custom CSS file (recommended: W3CSS)
7. Especially designed to be easy to install on a remote Linux server and relatively few dependencies/gems
8. CSRF protection methods included
9. File session handler included

### Limitations

1. Not suitable for medium or large sites because it scales poorly with concurrent connections (inherent with CGI programming)
2. Does not natively support CRUD operations
3. URL hierarchy is flat, not tree-like. Allows routes that are subdirectories but these are implemented flatly not in a tree-like manner, thus searching the URL routing is order N.
4. No built-in authentication method or admin panel
5. Not a mature system - highly likely to have security holes. 
6. Not a replacement for existing Ruby web frameworks such as Rails, Camping, Sinatra, etc.


### Requirements
Relatively few dependencies. These are needed regardless of whether installing locally or on a remote server:

- Apache v 2.4
- Ruby v 3.x
- sqlite3
- These Ruby gems: sanitize, sqlite3, sequel

Is that really it? Yes. That is all you need. 

General installation info is below with links to detailed installation tutorial showing how to create an example website: a color generator that accepts comments and has the ability to favorite and unfavorite colors and can inform the user how they navigated the site.

## Why is it called Zurfbirb?

"Zurfbirb" is a play off the phrase "Surfing Bird", a humorous song which I enjoy. The final letters are "rb" for the programming language Ruby.

## What operating systems can you use Zurfbirb on?
In principle you can install it on anything that has the requirements above installed, regardless of chipset. Instructions are given in the Wiki for local or remote deployment at https://github.com/verachell/Zurfbirb/wiki 

Zurfbirb has been tested on remote Linux hosting with Ubuntu and Debian. While it has been tested locally on Raspberry Pi and Linux machines, it has not yet been tested locally on Apple or Windows. 

**Zurfbirb is best suited to the Linux ecosystem for ease of placing it in a production environment**. There is a detailed step by step quickstart tutorial for deploying it on a cheap remote server in the Wiki. There is no need to pay for an ongoing long-term VPS just to try out Zurfbirb: these instructions have been tested many times using VPS at hourly computing providers DigitalOcean (US) and Clouding.io (EU) for just a few cents at a time. Alternatively, a reputable free VPS hosting provider could be ideal a quick tryout (but not all free providers are reputable - do your own research and choose one that does not require credit card information).

Zurfbirb was originally developed locally on a Raspberry Pi running Debian. It has been tested on remote Linux servers running a) Ubuntu 24.04 and b) Debian 12.

Zurfbirb is not as well suited to Windows because of the difficulty of installing Apache on Windows. But if you have Apache on your Windows machine, by all means go ahead!

## Installation

**DISCLAIMER:** Zurfbirb is just "for fun" and is not a mature web library. Do not use with any sensitive information or on any computer or system you wish to keep secure. **Use at own risk!** I have made a good faith effort to implement sensible protections, but as with any new system it is likely to have security holes.

Instructions are given in the Wiki for remote or local deployment at https://github.com/verachell/Zurfbirb/wiki - this includes a tutorial for making an example website.

## Questions or problems?
If you are encountering any roadblocks - whether with installation or with usage, raise an issue on this repository! 

I will be happy to deal with any questions, problems or issues. Please note that while I have plenty of access to Ubuntu and Debian VPS's for replicating your issue and testing, I do not have access to Apple or Windows machines. You should still write in for Apple or Windows problems and I will do my best. 

The more issues that can be solved, the better this software will become. So don't hesitate to raise an issue.

## License & development info
Zurfbirb is licensed under the MIT license. This software was originally developed and tested by Veronique Chellgren using Ruby 3.3.0 on a Raspberry Pi (arm64 chipset) running Debian 12 with Apache 2.4 installed. This software was also tested on remote Linux VPS servers (x64 chipset) at DigitalOcean (U.S.) and Clouding.io (E.U.) on Ubuntu 24.04 and Debian 12 operating systems.

