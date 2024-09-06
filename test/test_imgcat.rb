# frozen_string_literal: true

require "test_helper"

class TestImgcat < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Imgcat::VERSION
  end

  def test_displays_image
    io = StringIO.new
    file = File.read("#{__dir__}/../screenshot.png")
    Imgcat.new(io).display(file)
    output = io.string

    expected = "\e]1337;File=inline=1;size=#{file.size}:"
    assert_operator output, :start_with?, expected

    expected = "\n\a\n"
    assert_operator output, :end_with?, expected
  end
end
