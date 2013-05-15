package "apache2" do
  case node[:platform]
  when "ubuntu"
    package_name "ubuntu-desktop"
  end
  action :install
end




