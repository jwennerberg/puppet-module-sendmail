require 'spec_helper'
describe 'sendmail' do

  context 'with defaults for all parameters on osfamily Solaris' do
    let (:facts) {
      { :domain   => 'example.com',
        :osfamily => 'Solaris',
      }
    }

    it { should contain_class('sendmail') }

    it {
      should contain_package('SUNWsndmr').with({
        'ensure'       => 'installed',
        'source'       => nil,
        'adminfile'    => nil,
        'responsefile' => nil,
      })
    }

    it {
      should contain_file('sendmail_cf').with({
        'ensure' => 'present',
        'path'   => '/etc/mail/sendmail.cf',
        'owner'  => 'root',
        'group'  => 'bin',
        'mode'   => '0444',
      }).with_content(/^DSmailhost.example.com$/)
    }

    it {
      should contain_service('sendmail-client').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }
    it {
      should contain_service('smtp').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }

  end

  context 'with relayhost set on osfamily solaris' do
    let (:facts) { { :osfamily => 'solaris' } }
    let (:params) { { :relayhost => 'smtp.domain.tld' } }

    it { should contain_class('sendmail') }

    it {
      should contain_file('sendmail_cf').with({
        'ensure' => 'present',
        'path'   => '/etc/mail/sendmail.cf',
        'owner'  => 'root',
        'group'  => 'bin',
        'mode'   => '0444',
      }).with_content(/^DSsmtp.domain.tld$/)
    }
  end

  context 'with local_mail_forward set on osfamily solaris' do
    let (:facts) { { :osfamily => 'solaris' } }
    let (:params) { { :local_mail_forward => 'domain.tld' } }

    it { should contain_class('sendmail') }

    it {
      should contain_file('sendmail_cf').with({
        'ensure' => 'present',
        'path'   => '/etc/mail/sendmail.cf',
        'owner'  => 'root',
        'group'  => 'bin',
        'mode'   => '0444',
      }).with_content(/^DHdomain.tld$/)
    }
  end

  context 'with sendmail.cf parameters set on osfamily Solaris' do
    let (:facts) { { :osfamily => 'Solaris' } }
    let (:params) {
      { :relayhost => 'smtp.domain.tld',
        :sendmail_cf_path => '/etc/mail/mail/sendmail.cf',
        :sendmail_cf_ensure => 'file',
        :sendmail_cf_owner => 'user',
        :sendmail_cf_group => 'group',
        :sendmail_cf_mode => '0644',
      }
    }

    it { should contain_class('sendmail') }

    it {
      should contain_file('sendmail_cf').with({
        'ensure' => 'file',
        'path'   => '/etc/mail/mail/sendmail.cf',
        'owner'  => 'user',
        'group'  => 'group',
        'mode'   => '0644',
      })
    }
  end

  context 'with package parameters set osfamily Solaris' do
    let (:facts) { { :osfamily => 'Solaris' } }
    let (:params) {
      { :package_name => 'SUNsmtp',
        :package_ensure => 'present',
        :package_source => '/net/srv/vol/file.pkg',
        :package_adminfile => '/net/srv/vol/adminfile',
        :package_responsefile => '/net/srv/vol/repsonsefile',
      }
    }

    it { should contain_class('sendmail') }

    it {
      should contain_package('SUNsmtp').with({
        'ensure'       => 'present',
        'source'       => '/net/srv/vol/file.pkg',
        'adminfile'    => '/net/srv/vol/adminfile',
        'responsefile' => '/net/srv/vol/repsonsefile',
      })
    }
  end

  context 'with service parameters set osfamily Solaris' do
    let (:facts) { { :osfamily => 'Solaris' } }
    let (:params) {
      { :service_name => 'sendmailsrv',
        :service_ensure => 'stopped',
        :service_enable => 'false',
      }
    }

    it { should contain_class('sendmail') }

    it {
      should contain_service('sendmailsrv').with({
        'ensure' => 'stopped',
        'enable' => 'false',
      })
    }
  end
end
