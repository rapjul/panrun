# frozen_string_literal: true

require 'minitest/autorun'
load File.expand_path('../panrun', __dir__)

class TestAdditions < Minitest::Test
  def test_get_args_skips_t_and_to
    meta = { 't' => 'epub', 'standalone' => true, 'pandoc_args' => ['--foo'] }
    args = get_args(meta)
    refute_includes args, '--t'
    refute_includes args, '--to'
    assert_includes args, '--standalone'
    assert_includes args, '--foo'
  end

  def test_resolve_target_format_validates_to
    formats = %w[html epub latex]
    meta = { 'epub' => { 'to' => 'epub' } }
    fmt, mo = resolve_target_format('epub', meta, formats)
    assert_equal 'epub', fmt
    assert_equal meta['epub'], mo

    meta_bad = { 'epub' => { 'to' => 'bogusfmt' } }
    assert_raises RuntimeError do
      resolve_target_format('epub', meta_bad, formats)
    end
  end

  def test_generate_output_filename_auto
    input = 'test/test-input.md'
    yaml = { 'title' => 'My Document' }
    meta_out = {}
    name = generate_output_filename(input, yaml, meta_out, 'epub')
    assert_equal 'my-document.epub', name
  end

  def test_flags_after_double_dash_forwarded
    argv = ['-f', 'test/test-input.md', '--', '--quiet', '--foo=bar']
    cmds = build_pandoc_invocations(argv)
    assert cmds.is_a?(Array)
    # ensure post `--` args are preserved in the pandoc invocation
    joined = cmds.first.join(' ')
    assert_includes joined, '--quiet'
    assert_includes joined, '--foo=bar'
  end

  def test_internal_flags_stripped_before_double_dash
    argv = ['-n', '-q', '-f', 'test/test-input.md']
    cmds = build_pandoc_invocations(argv)
    joined = cmds.first.join(' ')
    refute_includes joined, '-n'
    refute_includes joined, '-q'
  end

  def test_internal_flags_not_forwarded_when_after_input
    argv = ['-t', 'html', '-f', 'test/test-input.md', '--dry-run']
    cmds = build_pandoc_invocations(argv)
    joined = cmds.first.join(' ')
    refute_includes joined, '--dry-run'
  end

  def test_all_flag_expands_long
    argv = ['--all', '-f', 'test/test-input.md']
    cmds = build_pandoc_invocations(argv)
    assert_equal 3, cmds.length
    joined = cmds.map { |c| c.join(' ') }.join("\n")
    assert_includes joined, '-t epub'
    assert_includes joined, '-t html'
    assert_includes joined, '-t latex'
  end

  def test_all_flag_expands_short
    argv = ['-a', '-f', 'test/test-input.md']
    cmds = build_pandoc_invocations(argv)
    assert_equal 3, cmds.length
  end
end
