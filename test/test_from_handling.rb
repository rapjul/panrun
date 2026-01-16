require 'minitest/autorun'
require File.expand_path('../panrun', __dir__)

# ensure get_args recognizes --from in tests
def get_pandoc_opts()
  ['from']
end

class TestFromHandling < Minitest::Test
  def test_top_level_from_applied
    meta = {'html' => {}}
    apply_global_from(meta, 'markdown+hard_line_breaks')
    assert_equal 'markdown+hard_line_breaks', meta['html']['from']
    args = get_args(meta['html'])
    assert_includes args, '--from'
    assert_includes args, 'markdown+hard_line_breaks'
  end

  def test_per_output_overrides_top_level
    meta = {'html' => {'from' => 'markdown_github'}}
    apply_global_from(meta, 'markdown+smart')
    assert_equal 'markdown_github', meta['html']['from']
    args = get_args(meta['html'])
    assert_includes args, '--from'
    assert_includes args, 'markdown_github'
  end

  def test_default_file_from_applied
    meta = {'html' => {}}
    apply_global_from(meta, 'markdown+line_breaks')
    assert_equal 'markdown+line_breaks', meta['html']['from']
  end

  def test_get_meta_from_other_file_returns_file_top
    require 'tempfile'
    tf = Tempfile.new(['test_default', '.yaml'])
    tf.write("---\nfrom: markdown+tmp\noutput:\n  html:\n    standalone: true\n")
    tf.close

    m, args, file_top = get_meta_from_other_file({}, tf.path)
    assert_equal 'markdown+tmp', file_top['from']
    assert m['html']['standalone'] == true
  ensure
    tf.unlink if tf
  end

  def test_build_pandoc_args_full_flow
    require 'tempfile'
    tf = Tempfile.new(['test_doc', '.md'])
    tf.write("---\nfrom: markdown+special\noutput:\n  html:\n    standalone: true\n---\n# content\n")
    tf.close

    args = build_pandoc_args(tf.path, [tf.path, '-t', 'html'])
    assert_equal 'pandoc', args[0]
    assert_includes args, '--from'
    assert_includes args, 'markdown+special'
  ensure
    tf.unlink if tf
  end
end
