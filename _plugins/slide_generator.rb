require 'markdown'
require 'redcarpet'

class ImpressRenderer < Redcarpet::Render::HTML
  @@attrs = []
  @@current = 0
  @@head = ""

  def self.init_with_attrs att
    @@attrs = att
    @@current = 0
  end

  def hrule
    # this is how we later inject attributes into pages. what an awful hack.
    @@current += 1
    %{</div>
      <div class='step' #{@@attrs[@@current]}>
    }
  end

  def block_code code, lang
    "<pre><code class='prettyprint #{lang}'>#{code}</code></pre>"
  end

  def codespan code
    "<code class='inline prettyprint'>#{code}</code>"
  end

end


module Jekyll
  class UpcaseConverter < Converter
    safe true

    priority :low

    def matches(ext)
      ext =~ /prez/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(text)
      lines = text.split("\n")
      lines.drop_while { |l| l =~ /^\s*$/ }
      attrs = [""]
      new_lines = []
      lines.each_with_index do |line, i|
        if line =~ /^=(.*)$/ && (i == 0 || lines[i-1] =~ /^(-\s*){3,}$/)
          line =~ /^=(.*)$/
            attrs[attrs.size-1] = $~.to_a[1]
          next
        elsif line =~ /^(-\s*){3,}$/
          attrs << ""
        end
        new_lines << line
      end
      text = new_lines.join("\n")

      require 'redcarpet'
      ImpressRenderer.init_with_attrs attrs

      m = Redcarpet::Markdown.new(ImpressRenderer, :autolink => true, :fenced_code_blocks => true, :tables => true)
      m.render(text)
    end
  end
end
