require_relative "default_spec"

certs_dir = case os[:family]
            when "freebsd"
              "/usr/local/etc/ssl/certs"
            else
              "/etc/ssl/certs"
            end

describe file certs_dir do
  it { should exist }
  it { should be_directory }
end

describe file "#{certs_dir}/localhost.pem" do
  it { should exist }
  it { should be_file }
  its(:content) { should match(/-----BEGIN CERTIFICATE-----/) }
end

describe command "(echo 'GET / HTTP/1.0'; echo; sleep 1) | openssl s_client -host localhost -port 3000 -servername localhost -CAfile #{certs_dir}/../ca.pem -showcerts" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/issuer=CN = Sensu Test CA/) }
  its(:stdout) { should match(/subject=CN = localhost/) }
  its(:stdout) { should match(/Protocol\s+:\s+TLSv1\.3/) }
  its(:stdout) { should match(%r{HTTP/1\.0 200 OK}) }

  # fail if the cert is signed with profile agent
  its(:stdout) { should_not match(/unsupported certificate purpose/) }
end
