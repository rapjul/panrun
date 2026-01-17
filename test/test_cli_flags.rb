# frozen_string_literal: true

require 'minitest/autorun'
load File.expand_path('../panrun', __dir__)

class TestCLIFlags < Minitest::Test
  def test_get_cli_targets
    argv = ['-t', 'html', '-t', 'epub', 'doc.md']
    targets = get_cli_targets(argv)
    assert_equal %w[html epub], targets
  end

  def test_parse_cli_flags
    argv = ['-t', 'html', '--force', '--dry-run', '--verbose', '--log', 'my.log']
    flags = parse_cli_flags(argv)
    assert flags[:force]
    assert flags[:dry_run]
    assert flags[:verbose]
    assert_equal 'my.log', flags[:log]
  end
end
