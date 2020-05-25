require_relative "default_spec"

certs_dir = case os[:family]
            when "freebsd"
              "/usr/local/etc/ssl/certs"
            else
              "/etc/ssl/certs"
            end

ca_cert = "#{certs_dir}/../ca.pem"
# XXX 8080 (API) and 8081 (agent communication) cannot be enabled
ports_http = [
  2379, 2380, # etcd
  3000        # Web UI
]

describe file certs_dir do
  it { should exist }
  it { should be_directory }
end

describe file "#{certs_dir}/localhost.pem" do
  it { should exist }
  it { should be_file }
  its(:content) { should match(/-----BEGIN CERTIFICATE-----/) }
end

ports_http.each do |port|
  describe command "(echo 'GET / HTTP/1.0'; echo; sleep 1) | openssl s_client -connect 127.0.0.1:#{port} -servername 127.0.0.1 -CAfile #{ca_cert}" do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/issuer=CN = Sensu Test CA/) }
    its(:stdout) { should match(/subject=CN = localhost/) }
    its(:stdout) { should match(/-----BEGIN CERTIFICATE-----/) }
    its(:stdout) { should match(%r{HTTP/1\.0 \d{3}}) }
  end
end
