# == Class: sendmail
#
# Module to manage sendmail
#
class sendmail (
  $relayhost            = "mailhost.${::domain}",
  $local_mail_forward   = $::domain,
  $domain_masquerade    = $::domain,
  $package_ensure       = 'installed',
  $package_name         = 'USE_DEFAULTS',
  $package_source       = undef,
  $package_adminfile    = undef,
  $package_responsefile = undef,
  $service_enable       = true,
  $service_ensure       = 'running',
  $service_name         = 'USE_DEFAULTS',
  $sendmail_cf_ensure   = 'present',
  $sendmail_cf_path     = '/etc/mail/sendmail.cf',
  $sendmail_cf_owner    = 'USE_DEFAULTS',
  $sendmail_cf_group    = 'USE_DEFAULTS',
  $sendmail_cf_mode     = 'USE_DEFAULTS',
) {

  case $::osfamily {
    Solaris: {
      $default_package_name = 'SUNWsndmr'
      $default_service_name = ['sendmail-client','smtp']
      $default_sendmail_cf_owner = 'root'
      $default_sendmail_cf_group = 'bin'
      $default_sendmail_cf_mode = '0444'
    }
    default: {
      fail("sendmail is supported on osfamily Solaris. Your osfamily identified as ${::osfamily}")
    }
  }

  if $package_name == 'USE_DEFAULTS' {
    $package_name_real = $default_package_name
  } else {
    $package_name_real = $package_name
  }

  if $service_name == 'USE_DEFAULTS' {
    $service_name_real = $default_service_name
  } else {
    $service_name_real = $service_name
  }

  if $sendmail_cf_owner == 'USE_DEFAULTS' {
    $sendmail_cf_owner_real = $default_sendmail_cf_owner
  } else {
    $sendmail_cf_owner_real = $sendmail_cf_owner
  }

  if $sendmail_cf_group == 'USE_DEFAULTS' {
    $sendmail_cf_group_real = $default_sendmail_cf_group
  } else {
    $sendmail_cf_group_real = $sendmail_cf_group
  }

  if $sendmail_cf_mode == 'USE_DEFAULTS' {
    $sendmail_cf_mode_real = $default_sendmail_cf_mode
  } else {
    $sendmail_cf_mode_real = $sendmail_cf_mode
  }

  $service_enable_type = type($service_enable)
  if $service_enable_type == 'string' {
    $service_enable_real = str2bool($service_enable)
  } else {
    $service_enable_real = $service_enable
  }

  validate_re($package_ensure, '^installed|^present|^absent')
  validate_re($service_ensure, '^running|^stopped')
  validate_re($sendmail_cf_ensure, '^present|^file|^absent')
  validate_string($relayhost)
  validate_string($sendmail_cf_owner_real)
  validate_string($sendmail_cf_group_real)
  validate_string($sendmail_cf_mode_real)
  validate_bool($service_enable_real)

  package { $package_name_real:
    ensure       => $package_ensure,
    source       => $package_source,
    adminfile    => $package_adminfile,
    responsefile => $package_responsefile,
  }

  file { 'sendmail_cf':
    ensure  => $sendmail_cf_ensure,
    path    => $sendmail_cf_path,
    owner   => $sendmail_cf_owner_real,
    group   => $sendmail_cf_group_real,
    mode    => $sendmail_cf_mode_real,
    content => template('sendmail/sendmail.cf.erb'),
    require => Package[$package_name_real],
  }

  service { $service_name_real:
    ensure    => $service_ensure,
    enable    => $service_enable,
    subscribe => File['sendmail_cf'],
  }
}
