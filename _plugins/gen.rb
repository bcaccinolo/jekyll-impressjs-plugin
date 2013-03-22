
# Post.new site, site.source , '', file_name

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

  def self.set_head head
    @@head = head
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

  def ____doc_header
    %{<!DOCTYPE html>
<html>
  <head>
    <link href="css/reset.css" rel="stylesheet" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=1024" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <link rel="shortcut icon" href="css/favicon.png" />
    <link rel="apple-touch-icon" href="css/apple-touch-icon.png" />
    <!-- Code Prettifier: -->
<link href="css/highlight.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="js/highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>

    <link href="css/style.css" rel="stylesheet" />
#{@@head}
  </head>

  <body>
  <div class="fallback-message">
  <p>Your browser <b>doesn't support the features required</b> by impress.js, so you are presented with a simplified version of this presentation.</p>
  <p>For the best experience please use the latest <b>Chrome</b>, <b>Safari</b> or <b>Firefox</b> browser.</p>
  </div>
    <div id="impress">
    <div class='step' #{@@attrs[0]}>
    }
  end

  def ____doc_footer
    %{
      </div>
    <script src="js/impress.js"></script>
    <script>impress().init();</script>
  </body>
</html>
    }
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
  # if File.exist?(STYLESHEET_HEAD)
  #   ImpressRenderer.set_head(File.read(STYLESHEET_HEAD))
  # else
  #   ImpressRenderer.set_head("")
  # end

  m = Redcarpet::Markdown.new(ImpressRenderer, :autolink => true, :fenced_code_blocks => true, :tables => true)
  m.render(text)
    end
  end
end
