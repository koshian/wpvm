#
# Cookbook Name:: setup
# Recipe:: default
#
# Copyright 2014, Sugano `Koshian' Yoshihisa(E)
#
# All rights reserved - GPLv2
#
MYSQL_ROOT_PASSWORD = 'root'
MYSQL_WPVM_USER = 'username'
MYSQL_WPVM_PASSWORD = 'password'
MYSQL_DATABASE_NAME = 'wordpress'

HOSTNAME='wpvm.lvh.me'
WP_SETUP_SQL='/tmp/wpsetup.sql'

["apache2", "php5", "php5-gd",
 "php5-mysql", "mysql-server", "mysql-client"].each do |p|
  package p do
    action :install
  end
end

execute "mysql_setup" do
  command "/usr/bin/mysql -u root < #{WP_SETUP_SQL}"
  action :nothing
end
 
template WP_SETUP_SQL do
  source 'mysql_setup.sql.erb'
  variables({
    :username => MYSQL_WPVM_USER,
    :password => MYSQL_WPVM_PASSWORD,
    :database => MYSQL_DATABASE_NAME
  })
  notifies :run, "execute[mysql_setup]", :immediately
end

script "install_wordpress" do
  interpreter "bash"
  user "root"
  code <<-__EOC__
    wget -O- https://wordpress.org/latest.tar.gz | tar xzfv - -C /var/www;
    chown -R www-data:www-data /var/www/wordpress
__EOC__
end

template "/etc/apache2/sites-available/#{HOSTNAME}" do
  source 'wpvm.httpd.conf.erb'
  action :create
  variables({:hostname => HOSTNAME})
end

script "enable_wpvm" do
  interpreter 'bash'
  user "root"
  code "a2ensite #{HOSTNAME}"
end

execute "restart httpd" do
  command '/etc/init.d/apache2 restart'
end
