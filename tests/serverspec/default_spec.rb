require "spec_helper"
require "serverspec"

package = nil
service = "sensu-backend"
config  = "/etc/sensu/backend.yml"
user    = "sensu"
group   = "sensu"
ports   = [3000, 8080]
log_dir = "/var/log/sensu"
db_dir  = "/var/lib/sensu/sensu-backend"
cache_dir = "/var/cache/sensu/sensu-backend"
state_dir = "/var/lib/sensu/sensu-backend"
admin_user = "admin"
admin_password = "P@ssw0rd!"
default_group = "root"
extra_packages = []

case os[:family]
when "ubuntu"
  package = "sensu-go-backend"
  extra_packages = ["sensu-go-cli"]
when "freebsd"
  package = "sysutils/sensu-go"
  config = "/usr/local/etc/sensu-backend.yml"
  db_dir = "/var/db/sensu/sensu-backend"
  state_dir = "/var/db/sensu/sensu-backend"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end

extra_packages.each do |p|
  describe package p do
    it { should be_installed }
  end
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
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
  end
when "ubuntu"
  describe file("/etc/default/sensu-backend") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
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

describe command("sensuctl configure -n --url http://127.0.0.1:8080 --username #{Shellwords.escape(admin_user)} --password #{Shellwords.escape(admin_password)} --format yaml") do
  before(:all) do
    Specinfra.backend.run_command("rm -rf /root/.config/sensu")
  end
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(/Using Basic Auth in HTTP mode is not secure, use HTTPS/) }
  its(:stdout) { should eq "" }
end
