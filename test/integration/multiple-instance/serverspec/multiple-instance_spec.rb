require 'serverspec'

# Required by serverspec
set :backend, :exec

describe "Kafka" do

  describe "broker 0" do
    it "is listening" do
      expect(port(9092)).to be_listening
    end

    # it "has JMX listening" do
    #   expect(port(9192)).to be_listening
    # end

    it "has a running service of kafka" do
      expect(service("kafka-broker-0")).to be_running
    end

    it "has a log directory " do
      expect(file("/var/log/kafka/broker-0")).to be_directory
    end

    it "has a log file" do
      expect(file("/var/log/kafka/broker-0/server.log")).to be_file
    end
  end

  describe "broker 1" do
    it "is listening" do
      expect(port(9093)).to be_listening
    end

    # it "has JMX listening" do
    #   expect(port(9193)).to be_listening
    # end

    it "has a running service of kafka" do
      expect(service("kafka-broker-1")).to be_running
    end

    it "has a log directory " do
      expect(file("/var/log/kafka/broker-1")).to be_directory
    end

    it "has a log file" do
      expect(file("/var/log/kafka/broker-1/server.log")).to be_file
    end
  end

  describe "broker 2" do
    it "is listening" do
      expect(port(9099)).to be_listening
    end

    # it "has JMX listening" do
    #   expect(port(9194)).to be_listening
    # end

    it "has a running service of kafka" do
      expect(service("kafka-broker-2")).to be_running
    end

    it "has a log directory " do
      expect(file("/var/log/kafka/broker-2")).to be_directory
    end

    it "has a log file" do
      expect(file("/var/log/kafka/broker-1/server.log")).to be_file
    end

    it "has an overridden config file" do
      config_file = file("/usr/local/kafka/config/kafka-broker-2.properties")
      expect(config_file).to be_file
      expect(config_file).to contain("broker.id=2")
      expect(config_file).to contain("host.name=127.0.0.1")
    end
  end

end
