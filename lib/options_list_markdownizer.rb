class OptionsListMarkdownizer
  def call(command)
    ui = Gem::SilentUI.new
    Gem::DefaultUserInteraction.use_ui ui do
      # Invoke the Ruby options parser by asking for help. Otherwise the
      # options list in the parser will never be initialized.
      command.show_help
    end

    parser = command.send(:parser)
    options = ''
    helplines = parser.summarize
    helplines.each do |helpline|
      break if (helpline =~ /Arguments/) || (helpline =~  /Summary/)
      next if helpline.strip == ''

      helpline = markdownize_options helpline

      if helpline =~ /^\s{10,}(.*)/
        options = options[0..-2] + " #{$1}\n"
      else
        if helpline =~ /^(.+)\s{2,}(.*)/
          helpline = "#{$1} - #{$2}"
        end
        if helpline =~ /options/i
          options += "\n### #{helpline.strip.delete_suffix(":")}\n\n"
        else
          options += "* #{helpline.strip}\n"
        end
      end
    end
    options
  end

  # Marks options mentioned on the given summary line
  def markdownize_options(line)
    # Mark options up as code (also prevents change of -- to &ndash;)
    line.sub(/^(\s*)((-\w, )*--[^\s]+)( [A-Z_\[\]]+)*(\s{3,})/, '\1`\2\4`\5')
  end
end
