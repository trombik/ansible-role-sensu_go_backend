require "spec_helper"
require "serverspec"

package = nil
service = "sensu-backend"
config  = "/etc/sensu-backend.yml"
user    = "sensu"
group   = "sensu"
ports   = [3000, 8080]
log_dir = "/var/log/sensu"
db_dir  = "/var/lib/sensu/sensu-backend"
cache_dir = "/var/cache/sensu/sensu-backend"
state_dir = "/var/lib/sensu/sensu-backend"

case os[:family]
when "freebsd"
  package = "sysutils/sensu-go"
  config = "/usr/local/etc/sensu-backend.yml"
  db_dir = "/var/db/sensu/sensu-backend"
  state_dir = "/var/db/sensu/sensu-backend"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("# Managed by ansible") }
  its(:content_as_yaml) { should include("state-dir" => state_dir) }
  its(:content_as_yaml) { should include("cache-dir" => cache_dir) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(cache_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/sensu_backend") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
