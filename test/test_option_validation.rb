# frozen_string_literal: true

require 'minitest/autorun'
load File.expand_path('../panrun', __dir__)

class TestOptionValidation < Minitest::Test
  def test_validate_meta_options_detects_unknown
    # stub get_pandoc_opts to a known list
    def get_pandoc_opts
      ['standalone']
    end
    meta_out = { 'standalone' => true, 'foo' => 'bar', 'pandoc_args' => ['--foo'] }
    unknown = validate_meta_options(meta_out)
    assert_equal ['foo'], unknown
  ensure
    load File.expand_path('../panrun', __dir__)
  end
end
