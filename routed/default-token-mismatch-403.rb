h1("403 Token mismatch", :style => "color:red")
pg("A security token was missing or has expired. Please go back to the previous page and try your request again")
hr
pg(em_v("Default Token Mismatch 403 page provided by Zurfbirb. If you are the site administrator, you'll likely want to change the Token Mismatch route in config.rb so it points to YOUR token mismatch page"))