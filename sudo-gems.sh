echo "Installing gems and dependencies"
echo "On most Linux systems it will ask you for your password (not root's) to run as root."
# install dependencies of gems
sudo apt-get install build-essential
sudo apt-get install pkgconf
sudo apt-get install sqlite3
# install gems
sudo gem install sanitize
sudo gem install sqlite3
sudo gem install sequel
