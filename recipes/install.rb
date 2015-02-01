# encoding: UTF-8
# Cookbook Name:: kafka_broker
# Recipe:: install
#

include_recipe "java" if node["kafka_broker"]["install_java"]

version_tag = "kafka_#{node["kafka_broker"]["scala_version"]}-#{node["kafka_broker"]["version"]}"
download_url = ::File.join(node["kafka_broker"]["mirror"], "#{node["kafka_broker"]["version"]}/#{version_tag}.tgz")
download_path = ::File.join(Chef::Config[:file_cache_path], "#{version_tag}.tgz")

user node["kafka_broker"]["user"] do
  comment node["kafka_broker"]["user"]
  system true
  shell "/bin/false"
end

directory node["kafka_broker"]["install_dir"] do
  recursive true
  owner node["kafka_broker"]["user"]
end

remote_file download_path do
  source download_url
  backup false
  checksum node["kafka_broker"]["checksum"]
  notifies :run, "execute[unzip kafka source]"
  not_if { ::File.exist?(::File.join(node["kafka_broker"]["install_dir"], version_tag)) }
end

execute "unzip kafka source" do
  command "tar -zxvf #{download_path} -C #{node["kafka_broker"]["install_dir"]}"
  not_if { ::File.exist?(::File.join(node["kafka_broker"]["install_dir"], version_tag)) }
end
