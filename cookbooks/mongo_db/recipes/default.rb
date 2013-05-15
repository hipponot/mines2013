# Add 10gen to apt repos list
apt_repository "add-10gen-repo" do
    uri "http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
    distribution "dist"
    components ["10gen"]
    action :add
end

# import 10gen GPG key
execute "add_apt_key" do
  command "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
  action :run
  notifies :add, resources(:apt_repository => "add-10gen-repo")
end

# Install mongo
package "mongodb-10gen" do
    action [:install, :upgrade]
    options "--force-yes"
end


