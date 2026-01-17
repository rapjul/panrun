# frozen_string_literal: true

require 'minitest/autorun'
require 'tempfile'
load File.expand_path('../panrun', __dir__)

class TestMultiOutput < Minitest::Test
  def test_multiple_cli_targets
    tf = Tempfile.new(['doccli', '.md'])
    tf.write("---\noutput:\n  html:\n    standalone: true\n  epub:\n    standalone: true\n---\n# content\n")
    tf.close

    cmds = build_pandoc_invocations(['-t', 'html', '-t', 'epub', tf.path])
    assert_equal 2, cmds.length
    # ensure -t occurs before filename in each
    cmds.each do |c|
      assert c.index('-t') < c.index(tf.path)
    end
  ensure
    tf&.unlink
  end

  def test_yaml_outputs_list
    tf = Tempfile.new(['docyaml', '.md'])
    tf.write("---\noutputs:\n  - html\n  - epub\n  html:\n    standalone: true\n  epub:\n    standalone: true\n---\n# content\n")
    tf.close

    cmds = build_pandoc_invocations([tf.path])
    assert_equal 2, cmds.length
  ensure
    tf&.unlink
  end

  def test_auto_filename_overwrite_error
    tf = Tempfile.new(['docauto', '.md'])
    tf.write("---\noutputs:\n  - html\n  html:\n    standalone: true\nauto-filename: true\n---\n# Unique Title\n")
    tf.close

    # simulate existing file
    # generate expected filename
    formats = get_supported_formats
    _, mo = resolve_target_format('html', { 'html' => { 'standalone' => true } }, formats)
    outname = generate_output_filename(tf.path, load_yaml(tf.path), mo, 'html', false)
    File.write(outname, 'existing')

    err = assert_raises RuntimeError do
      build_pandoc_invocations([tf.path])
    end
    assert_match(/already exists/, err.message)
  ensure
    tf&.unlink
    File.delete(outname) if outname && File.exist?(outname)
  end

  def test_auto_filename_overwrite_allowed_with_force
    tf = Tempfile.new(['docauto2', '.md'])
    tf.write("---\noutputs:\n  - html\n  html:\n    standalone: true\nauto-filename: true\n---\n# Another Title\n")
    tf.close

    formats = get_supported_formats
    _, mo = resolve_target_format('html', { 'html' => { 'standalone' => true } }, formats)
    outname = generate_output_filename(tf.path, load_yaml(tf.path), mo, 'html', false)
    File.write(outname, 'existing')

    # should not raise when --force present
    cmds = build_pandoc_invocations(['--force', tf.path])
    assert(cmds.any? { |c| c.include?('--output') })
  ensure
    tf&.unlink
    File.delete(outname) if outname && File.exist?(outname)
  end
end
