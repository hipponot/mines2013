cookbook_file File.join('/home/vagrant', '.bash_profile') do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source "bash_profile"
end

cookbook_file File.join('/home/vagrant', '.bash_profile') do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source "bash_profile"
end

cookbook_file File.join('/home/vagrant', '.bash_aliases') do
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  source "bash_aliases"
end

directory File.join('/home/vagrant', 'bin') do
  owner "vagrant"
  group "vagrant"
  mode 00755
  action :create
end

remote_directory File.join('/home/vagrant', 'bin') do
  files_backup 0
  files_owner 'vagrant'
  files_group 'vagrant'
  files_mode 0755
  source "bin"
end



