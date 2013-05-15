
package "curl" do
  package_name "curl"
  action :install
end

package "make" do
  package_name "make"
  action :install
end

package "g++" do
  package_name "g++"
  action :install
end

package "git" do
  package_name "git"
  action :install
end

package "nginx" do
  package_name "nginx"
  action :upgrade
end

# RVM needs this package to install correctly
package "git-core" do
  package_name "git-core"
  action :install
  notifies :run, "execute[install RVM]", :immediately
end

execute "install RVM" do
  cwd '/home/vagrant'
  action :nothing
  command "su vagrant -c 'curl -#L https://get.rvm.io | bash -s stable --autolibs=3 --ruby=1.9.3'"
end






