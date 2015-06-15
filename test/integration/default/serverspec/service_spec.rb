require 'serverspec'

# Required by serverspec
set :backend, :exec

describe "Kafka broker" do

  it "is listening on port 9092" do
    expect(port(9092)).to be_listening
  end

  it "is listening on port 9093" do
    expect(port(9093)).to be_listening
  end

  it "has a running service of kafka" do
    expect(service("kafka")).to be_running
  end

end