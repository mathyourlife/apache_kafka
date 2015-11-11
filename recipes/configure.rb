# encoding: UTF-8
# Cookbook Name:: apache_kafka
# Recipe:: configure
#

[
  node["apache_kafka"]["config_dir"],
  node["apache_kafka"]["bin_dir"],
  node["apache_kafka"]["data_dir"],
  node["apache_kafka"]["log_dir"]
].each do |dir|
  directory dir do
    recursive true
    owner node["apache_kafka"]["user"]
  end
end

%w{ kafka-server-start.sh kafka-run-class.sh kafka-topics.sh }.each do |bin|
  template ::File.join(node["apache_kafka"]["bin_dir"], bin) do
    source "bin/#{bin}.erb"
    owner "kafka"
    action :create
    mode "0755"
    variables(
      :config_dir => node["apache_kafka"]["config_dir"],
      :bin_dir => node["apache_kafka"]["bin_dir"]
    )
    notifies :restart, "service[kafka]", :delayed
  end
end

def create_broker_configuration(broker_config)
  zookeeper_connect = node["apache_kafka"]["zookeeper.connect"]
  zookeeper_connect = "localhost:2181" if zookeeper_connect.nil?

  template ::File.join(node["apache_kafka"]["config_dir"], broker_config["broker_config_file"]) do
    source "properties/server.properties.erb"
    owner "kafka"
    action :create
    mode "0644"
    variables(
      :broker_id => broker_config["broker_id"],
      :port => broker_config["port"],
      :zookeeper_connect => zookeeper_connect,
      :log_dirs => broker_config["data_dir"],
      :entries => broker_config["entries"]
    )
    notifies :restart, "service[kafka]", :delayed
  end
end

broker_configs = Array.new(node["apache_kafka"]["brokers"])

if broker_configs.nil? || broker_configs.empty?
  broker_id = node["apache_kafka"]["broker.id"]
  broker_id = 0 if broker_id.nil?
  broker_configs << {
    "broker_config_file" => "server.properties",
    "broker_id" => broker_id,
    "port" => node["apache_kafka"]["port"],
    "broker_config_file" => node["apache_kafka"]["conf"]["server"]["file"],
    "data_dir" => node["apache_kafka"]["data_dir"],
    "entries" => node["apache_kafka"]["conf"]["server"]["entries"]
  }
end

$counter = 0
def set_defaults(broker_config)
  broker_config["broker_id"] = broker_config["broker_id"] || $counter
  broker_config["broker_config_file"] = broker_config["broker_config_file"] || "server-#{broker_config['broker_id']}.properties"
  broker_config["port"] = broker_config["port"] || 9092 + $counter
  broker_config["data_dir"] = broker_config["data_dir"] || "/var/log/kafka/broker-#{broker_config['broker_id']}"
  broker_config["entries"] = []
  $counter = $counter + 1
end

broker_configs.each do |broker_config|
  config = Mash.from_hash(broker_config)
  set_defaults(config)
  create_broker_configuration(config)
end

template ::File.join(node["apache_kafka"]["config_dir"],
                     node["apache_kafka"]["conf"]["log4j"]["file"]) do
  source "properties/log4j.properties.erb"
  owner "kafka"
  action :create
  mode "0644"
  variables(
    :log_dir => node["apache_kafka"]["log_dir"],
    :entries => node["apache_kafka"]["conf"]["log4j"]["entries"]
  )
  notifies :restart, "service[kafka]", :delayed
end
