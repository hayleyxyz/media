# This script is run (privileged) on the vagrant guest after running "vagrant up" for the first time.
# It will:
# * Install required packages
# * Install composer
# * Update OS hostname
# * Add apache vhost for this application and update any other required config
# * Generate a .env config file for the application and run other required tasks
#

# Project-specific variables
NEW_HOSTNAME="media-vm"
MYSQL_DB="media"
MYSQL_HOST="127.0.0.1"
MYSQL_USER="root" # Should be "root" if using localhost mysql host
MYSQL_PASSWORD="kawaii"

# GitHub OAuth token composer uses to avoid rate limiting.
# Get a new token from https://github.com/settings/tokens/new?scopes=repo&description=jessie64
GITHUB_OAUTH_TOKEN="a39c9b1a33b55165f7a9de036b7b07fcd1a18cbd"

# End of configuration --- edit below with caution!

# Update apt cache
apt-get update

# Set mysql root password upfront to disable prompt from asking while installing mysql-server package
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
apt-get -y install mysql-server

# Install the rest of the dependencies
apt-get -y install \
    apache2 \
    php5 \
    php5-mysql \
    php5-mcrypt \
    php5-curl \
    php5-imagick \
    php5-gd \
    curl \
    mysql-client \
    git

# Install composer
curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin

# Set github oauth token to avoid rate limit issues
composer config --global github-oauth.github.com "$GITHUB_OAUTH_TOKEN"

# Install rocketeer
curl -sS http://rocketeer.autopergamene.eu/versions/rocketeer.phar > /usr/local/bin/rocketeer
chmod +x /usr/local/bin/rocketeer

# Update hostname
echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
echo "$NEW_HOSTNAME" > /etc/hostname
hostname -F /etc/hostname

# Set ServerName directive on apache globally to suppress warnings on start
echo "ServerName $(hostname)" > /etc/apache2/conf-available/server-name.conf
a2enconf server-name

# Set static key for this machine (whitelisted in bitbucket etc.)
# DO NOT USE THIS KEY FOR PUBLICKEY AUTHENTICATION FOR ANY SERVERS (minus this VM)
mkdir /root/.ssh
chmod 0700 /root/.ssh
cat << 'EOF' > /root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAwg/mi95JSuP8aHcUEyK+Bu5Mt6Iy9DOUh1HI26UMuW08K0YI
ZZnCXFQcK0I22vqx+mY5R0qg/29cRR4PDKk8Kmf75Vl6svUhLlA4dRoH/cJ62rjJ
0Tk/ETblaOkQKF89qUYxTi6T1Uifi+3iuFdMB+g2R33pIFoHAr3DXIuJE/aOdKg5
LFg04az2OeTwuvKxfwXbTNYyV9wGb5YJCC/VGVclJNhThUBbyPAc3BNA29Iu1cgV
fjGyEi35lF6rJqOhquxXGJrPTg5HzDCrdWOmHWgqWt0+wmsrmxJYL+9d0GiqRF27
VTHJ+KbeUVfV21PaMAGk6+ICjZmeJ8M9QAUGnwIDAQABAoIBAFpODemucgrQlueB
6iyRcT5GbBrT9sQesJJb440afBZZl7NHbqbg60oNteIHeQFjwaiVIzhiqRLUnmpn
d3db1WyiYNy0S921JlCn8e3ERE24z3Syou+ipQ98rTqpoeQ3lbkMuer4z8BjgCMc
evFvZikTzRZtqCtu2W5UIfIR2KMZu8VwhBilcdMqFOtQHKKWRaGWUumPqTNkv6ih
5HvvHZKVWqiGXOMEVC9VNN0RQGi6+Czg2zlPuV1mM2AH0u1VV6Ob7OfVlo0OpFkM
B9NBMBAN753QOBQxYPGoiQti8pBa4/TnI1EMgPJmilOJN5uODQ5iMiwEajB8RI8n
/m2zy6kCgYEA8cyT9spZYO6YUavS2zbAMF1TpTrChTxD9T7AgF0GfoPtWpmDnN98
q4ugwANNmAySSr10hE/wVSuy0zWm3BYZx/K03dc8FP9LZ9G6+vnA6ZHP6RPNZRrq
pe9PuC0EEf0Q/zVjrlmm69ngbWEkIIo75tTVAZujUTxUOFSuori265UCgYEAzXWa
HBypoWtYmiJlqGbeVVCR8qYYuSC/ntlnNyUZmD8C/AvY09B9Sts6ZGQS8yhil/xH
6j4SEFw/dctsDy/lrxowmlKIO/Ojy8JZaQDca1QmjrEOxtKPkEOiO+s2uj3AtiHc
8ilNFfwgv743y4nO35WBB30mOLwRSSeQbC2NPGMCgYEAoTSgTT/Y2OwZdxHUETxu
Y5BFDPqg500njaDZnHrosn5oRyfj/Dlvl7sOYBWTrNRs0BGBVhkphM8OeQvjBAZk
B89DUEeIEgOmlT/ZpivOtqn08FK4dDi+ygRDpOm2Nfv/UfaZT4sL42At5R6HhH5E
s3+fx2OpPaa4C5pBl9EIewUCgYBB6RgnLIq+XdFuoNo7y8RHWjF3xhDoUrkmHFgg
OKadUJmEgchtKtUGzo1M502s86etWiE34/GnjfBNuZRQyuzD34L3/sH1eZNyKkbE
iKItTDGSVPqIjcPAY/IHhs1nsafAxdw7U0SHaPqYiE0d3nefAjcCUAOS78Ib1bVe
/r3wQQKBgQDlPvfGCqeI9bMnr27X4V8mCwhZThlehctJUEKt0hPFubALTwkuPlZs
strPWkHTXC2s6X/zddPiQJWbLcYxHWeIIj7cj0jcxTyd3FEMtOuLzMm1/0Gt0Jqf
bKWnVDv4AJKv0VCNp69VKlIq2Y4R/tffPyBYctpUJIa4yIcV63ZPJw==
-----END RSA PRIVATE KEY-----
EOF

cat << 'EOF' > /root/.ssh/id_rsa.pub
# DO NOT USE THIS KEY FOR PUBLICKEY AUTHENTICATION FOR ANY SERVERS/SERVICES (minus this VM) YOU HAVE BEEN WARNED
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCD+aL3klK4/xodxQTIr4G7ky3ojL0M5SHUcjbpQy5bTwrRghlmcJcVBwrQjba+rH6ZjlHSqD/b1xFHg8MqTwqZ/vlWXqy9SEuUDh1Ggf9wnrauMnROT8RNuVo6RAoXz2pRjFOLpPVSJ+L7eK4V0wH6DZHfekgWgcCvcNci4kT9o50qDksWDThrPY55PC68rF/BdtM1jJX3AZvlgkIL9UZVyUk2FOFQFvI8BzcE0Db0i7VyBV+MbISLfmUXqsmo6Gq7FcYms9ODkfMMKt1Y6YdaCpa3T7CayubElgv713QaKpEXbtVMcn4pt5RV9XbU9owAaTr4gKNmZ4nwz1ABQaf root@jessie64
EOF

# Set proper perms on key files
chmod 0600 /root/.ssh/id_rsa
chmod 0644 /root/.ssh/id_rsa.pub

# Bypass known-host verification for bitbucket.
# Bypasses prompts while composer is installing packages from git repos
cat << 'EOF' >> /etc/ssh/ssh_config
# Bypass known-host verification for bitbucket
Host bitbucket.org
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF

# Run "composer install" on application folder
cd /vagrant
composer --no-ansi --no-progress --no-interaction install

# Enable apache modules
a2enmod rewrite

# Add apache vhost config for application
cat << 'EOF' > /etc/apache2/sites-available/vagrant.conf
<VirtualHost *:80>
    DocumentRoot /vagrant/public

    <Directory /vagrant/public>
        Require all granted

        RewriteEngine On

        # Redirect Trailing Slashes If Not A Folder...
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)/$ /$1 [L,R=301]

        # Handle Front Controller...
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^ index.php [L]
    </Directory>

    Alias /images /vagrant/storage/images
    Alias /files /vagrant/storage/files

    <Directory /vagrant/storage>
        Options -FollowSymLinks -ExecCGI
        Require all granted
        php_flag engine off
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Disable the default apache vhost and enable our new one
a2dissite 000-default
a2ensite vagrant

# Add www-data user to the vagrant group
# Allows access to /vagrant shared mount
usermod --append --groups vagrant www-data

# Reload changes
apache2ctl -k restart

# Set mysql client creds for automatic login
tee > ~vagrant/.my.cnf <<EOF
[client]
host=$MYSQL_HOST
database=$MYSQL_DB
user=$MYSQL_USER
password=$MYSQL_PASSWORD
EOF

# Update owner and remove access for other users
chmod go-rwx,u-x ~vagrant/.my.cnf
chown vagrant:vagrant ~vagrant/.my.cnf

# Create DB
# Run as vagrant user so it uses the user's .my.cnf
sudo -u vagrant mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DB" -D ""

# Set .env
if [ -f /vagrant/.env ];
then
    echo ".env file already exists, skipping auto configuration."
else
    replace "DB_HOST=localhost" "DB_HOST=$MYSQL_HOST" \
            "DB_DATABASE=homestead" "DB_DATABASE=$MYSQL_DB" \
            "DB_USERNAME=homestead" "DB_USERNAME=$MYSQL_USER" \
            "DB_PASSWORD=secret" "DB_PASSWORD=$MYSQL_PASSWORD" < /vagrant/.env.example > /vagrant/.env
fi



# Application setup
cd /vagrant
php artisan vendor:publish
php artisan migrate
php artisan key:generate

ARTISAN_OUTPUT=$(php artisan list --no-ansi)

# Generate helper files for IDE (check we have barryvdh/laravel-ide-helper package enabled)
if [[ $ARTISAN_OUTPUT =~ "ide-helper:generate" ]]; then php artisan ide-helper:generate; fi
if [[ $ARTISAN_OUTPUT =~ "ide-helper:models" ]]; then php artisan ide-helper:models --nowrite; fi
if [[ $ARTISAN_OUTPUT =~ "ide-helper:meta" ]]; then php artisan ide-helper:meta; fi
