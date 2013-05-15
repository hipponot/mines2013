NAGIOS_TAR = 'nagios-3.2.3.tar.gz'
NAGIOS_DIR = '/tmp/nagios-3.2.3'
NAGIOS_PLUGIN_TAR = 'nagios-plugins-1.4.11.tar.gz'
NAGIOS_PLUGIN_DIR = '/tmp/nagios-plugins-1.4.11'


ruby_block "nagios" do
  action :nothing
  block do
    `apt-get install -qq apache2`
    `apt-get install -qq libapache2-mod-php5`
    `apt-get install -qq build-essential`
    `/usr/sbin/useradd -m -s /bin/bash nagios`
    `usermod --password nagios nagios`
    `/usr/sbin/groupadd nagios`
    `/usr/sbin/usermod -G nagios nagios`
    `/usr/sbin/groupadd nagcmd`
    `/usr/sbin/usermod -a -G nagcmd nagios`
    `/usr/sbin/usermod -a -G nagcmd www-data`
    `cd /tmp; tar xzf #{NAGIOS_TAR}; cd #{NAGIOS_DIR}; ./configure --with-command-group=nagcmd; make all; make install; make install-init; make install-config; make install-commandmode`
    `cp #{File.join(File.dirname(__FILE__), "../files/default/contacts.cfg")} /usr/local/nagios/etc/objects/contacts.cfg`
    `cp #{File.join(File.dirname(__FILE__), "../files/default/nagios.cfg")} /usr/local/nagios/etc/nagios.cfg`
    `cp #{File.join(File.dirname(__FILE__), "../files/default/woot_api.cfg")} /usr/local/nagios/etc/objects/woot_api.cfg`
    `cd #{NAGIOS_DIR}; make install-webconf`
    `htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios`
    `/etc/init.d/apache2 reload`
    `cd /tmp; tar xzf #{NAGIOS_PLUGIN_TAR}; cd #{NAGIOS_PLUGIN_DIR}; ./configure --with-nagios-user=nagios --with-nagios-group=nagios; make; make install`
    `ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios`
    `/etc/init.d/nagios start`
  end
end

cookbook_file File.join('/tmp', NAGIOS_TAR) do
  mode 0755
  source NAGIOS_TAR
end

cookbook_file File.join('/tmp', NAGIOS_PLUGIN_TAR) do
  mode 0755
  source NAGIOS_PLUGIN_TAR
  notifies :create, "ruby_block[nagios]"
end
