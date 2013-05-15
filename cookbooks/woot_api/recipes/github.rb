

unless File.exist?("/home/vagrant/kudu")
  git "/home/vagrant/kudu" do
    user 'vagrant'
    repository "https://github.com/hipponot/kudu.git"
    reference "master"
    action :sync
  end
end




