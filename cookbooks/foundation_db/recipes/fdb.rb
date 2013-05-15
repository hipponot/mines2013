# Install bundler gem
#execute "install-client" do
#  command "gem install fdb-0.1.5.1-x86_64-linux.gem --no-rdoc --no-ri -q"
#end

cookbook_file "/tmp/foundationdb-server_0.1.5-1_amd64.deb" do
  source "foundationdb-server_0.1.5-1_amd64.deb"
  owner "root"
  group "root"
  mode "0644"
end

package "foundationdb-server" do
  provider Chef::Provider::Package::Dpkg
  source "/tmp/fdb.rb foundationdb-server_0.1.5-1_amd64.deb"
  action :install
end

cookbook_file "/tmp/fdb-node-0.1.5-1.tar.gz" do
  source "fdb-node-0.1.5-1.tar.gz"
  owner "root"
  group "root"
  mode "0644"
end

#execute "inflate-tarball" do
#  command "tar xvzf /tmp/fdb-node-0.1.5-1.tar.gz -C <target dir>"
#end

cookbook_file "/tmp/fdb-0.1.5.1-x86_64-linux.gem" do
  source "fdb-0.1.5.1-x86_64-linux.gem"
  owner "root"
  group "root"
  mode "0644"
end

gem_package "fdb-gem" do
  source "/tmp/fdb-0.1.5.1-x86_64-linux.gem"
  action :install
end
