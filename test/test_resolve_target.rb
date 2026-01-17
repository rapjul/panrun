# frozen_string_literal: true

require 'minitest/autorun'
load File.expand_path('../panrun', __dir__)

class TestResolveTarget < Minitest::Test
  def test_resolve_known_yaml_target_with_to
    meta = { 'ebook' => { 'to' => 'epub', 'standalone' => true } }
    formats = %w[html epub]
    fmt, mo = resolve_target_format('ebook', meta, formats)
    assert_equal 'epub', fmt
    assert_equal mo, meta['ebook']
  end

  def test_resolve_yaml_target_without_to_raises
    meta = { 'ebook' => { 'standalone' => true } }
    formats = %w[html epub]
    err = assert_raises RuntimeError do
      resolve_target_format('ebook', meta, formats)
    end
    assert_match(/no `to` field/, err.message)
  end

  def test_resolve_direct_pandoc_format
    meta = {}
    formats = get_supported_formats
    # choose a known format if available
    fmt_name = formats.find { |f| f.to_s.downcase == 'html' } || formats[0]
    fmt, mo = resolve_target_format(fmt_name, meta, formats)
    assert_equal fmt_name, fmt
    assert_equal mo, {}
  end

  def test_resolve_unknown_target_raises
    meta = {}
    formats = %w[html epub]
    err = assert_raises RuntimeError do
      resolve_target_format('bogusformat', meta, formats)
    end
    assert_match(/unknown target/, err.message)
  end
end
