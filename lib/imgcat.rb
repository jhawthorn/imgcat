# frozen_string_literal: true

require_relative "imgcat/version"
require "base64"

# https://iterm2.com/documentation-images.html
# https://iterm2.com/utilities/imgcat

class Imgcat
  class Error < StandardError; end

  RELEVANT_ENV = %w[TERM TERM_PROGRAM LC_TERMINAL]

  attr_reader :tty
  def initialize(tty = STDOUT, env: ENV)
    @tty = tty
    @env = env.slice(*RELEVANT_ENV)
  end

  def guess_terminal_program
    term = ENV["TERM"]
    term_program = ENV["TERM_PROGRAM"]
    if term_program == "iTerm.app" || ENV["LC_TERMINAL"] == "iTerm2"
      :iterm
    elsif term == "xterm-kitty"
      :kitty
      nil # unsupported for now
    elsif term_program == "WezTerm"
      :wezterm
    else
      nil
    end
  end

  def supported?
    !!guess_terminal_program
  end

  def display(image, name: nil, width: nil, height: nil, inline: true)
    print_osc
    @tty.printf "1337;File=inline=%i", (inline ? 1 : 0)
    @tty.printf ";size=%d", image.length
    #[ -n "$1" ] && printf ";name=%s" "$(printf "%s" "$1" | b64_encode)"
    #[ -n "$5" ] && printf ";width=%s" "$5"
    #[ -n "$6" ] && printf ";height=%s" "$6"
    #[ -n "$7" ] && printf ";preserveAspectRatio=%s" "$7"
    #[ -n "$8" ] && printf ";type=%s" "$8"
    @tty.printf ":%s", Base64.encode64(image)
    print_st
    @tty.puts
    #[ "$4" == "1" ] && echo "$1"
    #has_image_displayed=t
  end

  def tmux?
    term = ENV["TERM"]
    term&.start_with?("screen") || term&.start_with?("tmux")
  end

  def print_osc
    if tmux?
      @tty.write "\033Ptmux;\033\033]"
    else
      @tty.write "\033]"
    end
  end

  def print_st
    if tmux?
      @tty.write "\a\033\\"
    else
      @tty.write "\a"
    end
  end
end
