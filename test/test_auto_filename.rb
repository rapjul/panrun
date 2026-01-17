# frozen_string_literal: true

require 'minitest/autorun'
require 'tempfile'
load File.expand_path('../panrun', __dir__)

class TestAutoFilename < Minitest::Test
  def test_slugify_and_generate_filename_from_title
    tf = Tempfile.new(['doc', '.md'])
    tf.write("---\ntitle: My Fancy Title\noutput:\n  html:\n    standalone: true\n---\n# content\n")
    tf.close

    yaml = load_yaml(tf.path)
    meta = yaml['output'] || {}
    name = generate_output_filename(tf.path, yaml, meta['html'], 'html', false)
    assert_match(/my-fancy-title\.html$/, name)
  ensure
    tf&.unlink
  end

  def test_generate_filename_from_first_heading_and_date
    tf = Tempfile.new(['doc2', '.md'])
    tf.write("---\noutput:\n  html:\n    standalone: true\n---\n# The Heading Title\n")
    tf.close

    yaml = load_yaml(tf.path)
    meta = yaml['output'] || {}
    name = generate_output_filename(tf.path, yaml, meta['html'], 'html', true)
    assert_match(/the-heading-title_\d{4}-\d{2}-\d{2}\.html$/, name)
  ensure
    tf&.unlink
  end
end
