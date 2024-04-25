require 'spec_helper'

describe 'network' do

  context 'Supported OS - ' do

    ['Debian', 'RedHat'].each do |osfamily|

      operatingsystem = 'Debian' if osfamily == 'Debian'
      operatingsystem = 'RedHat' if osfamily == 'RedHat'

      context "#{osfamily} configuration via custom template" do

        let(:params) {{
          :config_file_template     => 'network/spec.conf',
          :config_file_options_hash => { 'opt_a' => 'value_a' },
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => '7',
        }}

        it {
          is_expected.to contain_file('network.conf').with_content(/This is a template used only for rspec tests/)
        }
        it {
          is_expected.to contain_file('network.conf').with_content(/value_a/)
        }

      end

      context "#{osfamily} configuration via custom content" do

        let(:params) {{
          :config_file_content    => 'my_content',
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => '7',
        }}

        it {
          is_expected.to contain_file('network.conf').with_content(/my_content/)
        }

      end

      context "#{osfamily} configuration via custom source file" do

        let(:params) {{
          :config_file_source => "puppet:///modules/network/spec.conf",
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => '7',
        }}

        it {
          is_expected.to contain_file('network.conf').with_source('puppet:///modules/network/spec.conf')
        }

      end

      context "#{osfamily} configuration via custom source dir" do

        let(:params) {{
          :config_dir_source => 'puppet:///modules/network/tests/',
          :config_dir_purge => true
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => '7',
        }}

        it {
          is_expected.to contain_file('network.dir').with_source('puppet:///modules/network/tests/')
        }

        it {
          is_expected.to contain_file('network.dir').with_purge('true')
        }

        it {
          is_expected.to contain_file('network.dir').with_force('true')
        }

      end

      context "#{osfamily} service restart disabling on config file change" do

        let(:params) {{
          :config_file_notify => '',
          :config_file_source => "puppet:///modules/network/spec.conf",
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
          :operatingsystemmajrelease => '7',
        }}

        it {
          is_expected.to contain_file('network.conf').without_notify
        }

      end

    end

  end

  context 'RedHat family specific' do

    context "RedHat service restart on config file change (default)" do

      let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemmajrelease => '7',
      }}
      let(:params) {{
        :config_file_source => "puppet:///modules/network/spec.conf",
      }}

      it {
        is_expected.to contain_file('network.conf').with_notify("Exec[network_restart]")
        is_expected.to contain_exec('network_restart').with_command("service network restart")
      }

    end

  end

  context 'Debian family specific' do

    context "Debian service restart on config file change (default)" do

      let(:facts) {{
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemmajrelease => '7',
      }}
      let(:params) {{
        :config_file_source => "puppet:///modules/network/spec.conf",
      }}

      it {
        is_expected.to contain_file('network.conf').with_notify("Exec[network_restart]")
        is_expected.to contain_exec('network_restart').with_command("/sbin/ifdown -a --force ; /sbin/ifup -a")
      }

    end

  end

  context 'Unsupported OS - ' do

    let(:facts) {{
      :osfamily        => 'BSD',
      :operatingsystem => 'Nexenta',
      :operatingsystemmajrelease => '7',
    }}

    it {
      expect { is_expected.to compile }.to raise_error()
    }

  end

end
