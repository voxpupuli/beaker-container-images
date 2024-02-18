# frozen_string_literal: true

# this is inspired by https://github.com/voxpupuli/voxpupuli-acceptance/blob/397055f9d9ff1d7da17a7955430ddcf35619d641/lib/voxpupuli/acceptance/spec_helper_acceptance.rb

require 'beaker_puppet_helpers'
require 'beaker-rspec'

collection = ENV['BEAKER_PUPPET_COLLECTION'] || 'puppet'

block_on hosts, run_in_parallel: true do |host|
  unless %w[none preinstalled].include?(collection)
    BeakerPuppetHelpers::InstallUtils.install_puppet_release_repo_on(host, collection)
  end
  package_name = ENV.fetch('BEAKER_PUPPET_PACKAGE_NAME', BeakerPuppetHelpers::InstallUtils.puppet_package_name(host, prefer_aio: collection != 'none'))
  host.install_package(package_name)

  # by default, puppet-agent creates /etc/profile.d/puppet-agent.sh which adds /opt/puppetlabs/bin to PATH
  # in our non-interactive ssh sessions we manipulate PATH in ~/.ssh/environment, we need to do this step here as well
  host.add_env_var('PATH', '/opt/puppetlabs/bin')
end
