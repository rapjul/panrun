# frozen_string_literal: true

require 'minitest/autorun'
load File.expand_path('../panrun', __dir__)

class TestSupportedFormats < Minitest::Test
  def test_normalize_format
    assert_equal 'markdown', normalize_format('markdown+hard_line_breaks-foo')
    assert_equal 'html', normalize_format('html')
    assert_nil normalize_format(nil)
  end

  def test_get_supported_formats_returns_array
    fmts = get_supported_formats
    assert_kind_of Array, fmts
    assert fmts.any? { |f| f.to_s.downcase == 'html' }, "expected installed pandoc to support 'html'"
  end

  def test_check_pandoc_available_errors_when_empty
    # stub get_supported_formats
    def get_supported_formats
      []
    end
    err = assert_raises RuntimeError do
      check_pandoc_available!
    end
    assert_match(/Install pandoc/, err.message)
  ensure
    # restore by reloading file
    load File.expand_path('../panrun', __dir__)
  end
end
