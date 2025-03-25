#! /bin/bash
chmod -R o+x ./*.rb

zbdir='/tmp/zurfbirb-' 
for i in {0..20}; do zbdir+=$(printf "%x" $(($RANDOM%16)) )
done

zbfname='zb-s-'
for i in {0..20}; do zbfname+=$(printf "%x" $(($RANDOM%16)) )
done

zbfname+='.txt'
keyfiledir=$HOME/'zurfbirb_for_apache'

if [ ! -d $keyfiledir ]
then
	mkdir $keyfiledir
fi

keyfname='zb-private-'
for i in {0..20}; do keyfname+=$(printf "%x" $(($RANDOM%16)) )
done

keyfname+='.key'

# set doc root if working in same directory as repo
# docroot='\nDOC_ROOT = "'$PWD'"'
# but in reality the repo gets unpacked into a subfolder, so doc root needs to be one level up
docroot='\nDOC_ROOT = "'${PWD%/*}'"'

linestowrite='\n$zb_sess_dirname = "'$zbdir'"\n$zb_sess_filename = "'$zbfname'"\n$zb_sess_crypt_key_file = "'$keyfiledir/$keyfname'"\n'



echo -e "$docroot\n$(cat config/config.rb)\n" > config/config.rb

echo -e $linestowrite >> config/sess-file-vars.rb

echo 'Private key directory was set to '$keyfiledir
echo 'Session file directory was set to '$zbdir

echo "Final step - need to finalize setup of a directory. On some Linux systems it will ask you for your password (not root's) to run this step as root."

sudo chown -R www-data:www-data $keyfiledir

# remove .gitignore files from otherwise empty directories
# they only exist because GitHub doesn't allow empty directories
rm templates/.gitignore
rm html/.gitignore
rm component_fns/.gitignore
rm scripts/.gitignore
rm public_auto_urls/.gitignore
rm forms/.gitignore
rm assets/images/.gitignore
rm assets/styles/.gitignore

# remove .git and .gitigore
rm -R .git
rm .gitignore

# move files out of the zurfbirb folder, first backing up the old .htaccess
mv ../.htaccess ../OLD_htaccess
mv -ft .. ./*
# move dotfiles, which would not otherwise be moved
mv -ft .. ./.*

# delete this script

# shred -u install.sh
