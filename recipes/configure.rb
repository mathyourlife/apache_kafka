# encoding: UTF-8
# Cookbook Name:: kafka_broker
# Recipe:: configure
#

directory node["kafka_broker"]["config_dir"] do
  recursive true
  owner node["kafka_broker"]["user"]
end
directory node["kafka_broker"]["bin_dir"] do
  recursive true
  owner node["kafka_broker"]["user"]
end
directory node["kafka_broker"]["log_dir"] do
  recursive true
  owner node["kafka_broker"]["user"]
end

%w{ kafka-server-start.sh kafka-run-class.sh kafka-topics.sh }.each do |bin|
  template ::File.join(node["kafka_broker"]["bin_dir"], bin) do
    source "bin/#{bin}.erb"
    owner "kafka"
    action :create
    mode "0755"
    variables(
      :config_dir => node["kafka_broker"]["config_dir"],
      :bin_dir => node["kafka_broker"]["bin_dir"],
      :log_dir => node["kafka_broker"]["log_dir"]
    )
    notifies :restart, "service[kafka]", :delayed
  end
end

broker_id = node["kafka_broker"]["broker.id"]
broker_id = 0 if broker_id.nil?

zookeeper_connect = node["kafka_broker"]["zookeeper.connect"]
zookeeper_connect = "localhost:2181" if zookeeper_connect.nil?

template ::File.join(node["kafka_broker"]["config_dir"],
                     node["kafka_broker"]["conf"]["server"]["file"]) do
  source "properties/server.properties.erb"
  owner "kafka"
  action :create
  mode "0644"
  variables(
    :broker_id => broker_id,
    :port => node["kafka_broker"]["port"],
    :zookeeper_connect => zookeeper_connect,
    :entries => node["kafka_broker"]["conf"]["server"]["entries"]
  )
  notifies :restart, "service[kafka]", :delayed
end

template ::File.join(node["kafka_broker"]["config_dir"],
                     node["kafka_broker"]["conf"]["log4j"]["file"]) do
  source "properties/log4j.properties.erb"
  owner "kafka"
  action :create
  mode "0644"
  variables(
    :log_dir => node["kafka_broker"]["log_dir"],
    :entries => node["kafka_broker"]["conf"]["log4j"]["entries"]
  )
  notifies :restart, "service[kafka]", :delayed
end
