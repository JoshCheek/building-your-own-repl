# HOSTED AT:
# hosted at http://quiz-ruby-object-model.herokuapp.com/


require 'redcarpet'
require 'pygments'
# from readme https://github.com/vmg/redcarpet
class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  end
end

def to_html(markdown)
  leading_space = (markdown.lines[1] || '')[/^\s+/]
  markdown      = markdown.gsub(/^ {0,#{leading_space}}/, '')
  Redcarpet::Markdown.new(HTMLwithPygments,
                           space_after_headers: true,
                           fenced_code_blocks:  true,
                           autolink:            true,
                      ).render(markdown)
end

def qa(q, a)
  {question: q, options: {}, answer: a, hint: '', further_thought: ''}
end

questions =
[
{ question: 'What is the `$LOAD_PATH`?',
  options:  {
    a: 'The shell\'s $PATH, split into an array',
    b: 'A cruel joke',
    c: 'An array of directories to search when you require a file',
    d: 'An array of loaded files',
  },
  answer: :c,
  hint:   'This is how your require statements know where to find the filework',
  further_thought: 'The shell does something very similar with the $PATH, in order to fidn the program you are invoking'
},{
  question: 'You have two files in the same directory, f1.rb and f2.rb,
    f1.rb has the line `require "f2"`. When you run it, you see
    "`require\': cannot load such file -- f2 (LoadError)"
    What is the problem? How do you fix it?',
    options: {
    a: "The problem is that your require statement needs double quotes around the filename",
    b: "The problem is that their directory isn't in `$LOAD_PATH` Fix it by adding their directory to the load path",
    c: "The problem is that Ruby is drunk and, fix it by telling it to go home.",
    d: "The problem is that you don't have the require gem installed, fix it with `gem install require`",
  },
  answer: :b,
  hint: 'How does Ruby find the files you require?',
  further_thought: '',
},
{ question: 'What method name is commonly used in Ruby to tell an object to "do what you do"',
  options: {
    a: 'call',
    b: 'invoke',
    c: 'execute',
    d: 'perform',
  },
  answer: :a,
    hint: 'This is the same method you use to call a block',
  further_thought: 'This doesn\'t mean it\'s bad to have another name',
},
{ question: '`__dir__` gives us what?',
  options: {
    a: 'The path to the root of the project',
    b: 'Trick question, this blows up',
    c: 'The path to the current file',
    d: 'The path to the current file\'s directory.'
  },
  answer: :d,
  hint: '',
  further_thought: '',
},
{ question: '`__FILE__` gives us what?',
  options: {
    a: 'The path to the root of the project',
    b: 'Trick question, this blows up',
    c: 'The path to the current file',
    d: 'The path to the current file\'s directory.'
  },
  answer: :c,
  hint: '',
  further_thought: '',
},
{ question: 'Say `$LOAD_PATH` is the array `["/a/b", "/c/d"]`,
     and there are files "/a/b/hellooo.rb" and "/c/d/hellooo.rb".
     If we require "hellooo.rb", what file will be required?',
     options: {
    a: '/a/b/hellooo.rb',
    b: '/c/d/hellooo.rb',
    c: 'neither file',
    d: 'both files',
  },
 answer: :a,
 hint: 'The $LOAD_PATH is searched with #find',
 further_thought: 'Your shell finds the program to execute this same way, when searching the $PATH',
},
{ question: 'If we were in the directory /Users/josh/Turing/numbermind
     and we saw the file "/Users/josh/Turing/numbermind/numbermind.rb",
     which wanted to require the file "/Users/josh/Turing/numbermind/lib/cli.rb"
     and it did this by saying `require "cli"`, what code would it need to have first
     in order for that to work?',
   options: {
     a: '`$LOAD_PATH.unshift(File.expand_path("lib/numbermind", __dir__))`',
     b: '`$LOAD_PATH.unshift(File.expand_path("lib/numbermind.rb", __dir__))`',
     c: '`$LOAD_PATH.unshift(File.expand_path("lib", __FILE__))`',
     d: '`$LOAD_PATH.unshift(File.expand_path("lib", __dir__))`',
   },
   answer: :d,
   hint:   'Pay attention to where the files are relative to each other',
   further_thought: 'Unshift here is just placing the new directory at the beginning of the array.
    It\'s just like `$LOAD_PATH << File.expand_path(\'lib\', __dir__)`, except
    that would place the directory at the back of the array.',
},
{ question: 'If you had three files:

     * game.rb       requires lib/cli.rb
     * lib/cli.rb    requires lib/board.rb
     * lib/board.rb  doesn\'t require anything

     Where would you fix the load path?',
 options: {
   a: 'game.rb',
   b: 'lib/cli.rb',
   c: 'lib/board.rb',
   d: 'You don\'t need to fix the load path',
 },
 answer: :a,
 hint: 'Where do you enter the program?',
 further_thought: "Once the load path is fixed, it is fixed
    (it's stored in a $global_variable, so everyone sees the same array).
    So you should fix the load path at the entry point to the program.
    Then the rest of the program can assume that the path is correct.",
},
{ question: "Given these code samples, which one probably has higher test coverage?

```ruby
lib_dir = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib_dir)
require 'cli'
CLI.new($stdin, $stdout).call
```

and

```ruby
lib_dir = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib_dir)
require 'cli'
cli = CLI.new
$stdout.puts cli.welcome_message
loop do
  break if cli.game_over?
  input = $stdin.gets
  break unless input
  output = cli.call(input)
  $stdout.puts
end
```
",
  options: {a: 'The first one', b: 'The second one'},
  answer: :a,
  hint:   '',
  further_thought: <<-THOUGHT
    Being in the binary, where simply requiring this file kicks off a game,
    something we don't want to happen in the middle of our tests,
    the code in these files is probably not tested.
    If we wanted to test it, we'd have to start a new process
    (meaning approximately `system "ruby", "numbermind.rb"`
    If you'd like to play with this, look into something like this: http://www.rubydoc.info/stdlib/open3/Open3.capture3)
  THOUGHT
},
{ question: 'In the previous question, which of the two code examples has a better separation between logic and environment?',
  options: {a: 'The first one', b: 'The second one'},
  answer:   :b,
  hint: '',
  further_thought: <<-THOUGHT
    Notice that the CLI doesn't have any knowledge of input streams and output streams.
    This means it can deal with simple strings, which are much easier to work with.
    We pulled the painful pieces up into the binary, and can now interact with that code easily.

    Also notice that CLI doesn't have a loop in it, we pulled that up into the binary.
    This means that the CLI is dramatically more flexible. For example, we could test it like this:

    ```ruby
    def test_i_am_back_at_the_main_menu_after_selecting_instructions
      cli = CLI.new
      # view instructions, get prompted again
      to_print = cli.call("i").downcase
      assert_includes to_print, "enter 'p' to play"
      assert_includes to_print, 'enter your command'

      # can quit from the main menu
      refute cli.game_over?
      assert_includes cli.call("q").downcase, "goodbye"
      assert cli.game_over?
    end
    ```

    See, in that test, how easy it is to look at each instruction independently?
    We can assert the state of `cli.game_over?` between the two inputs.
    If the cli itself took care of the loop, then we wouldn't be able to
    "pause" it at this point in order to make these assertions.

    NOTE: This example isn't always possible without further decoupling
          (with mastermind, for example, you have the game loop inside of the menu loop)

    Now, we still need to be apprehensive, there's a little bit of logic in here,
    and it's almost certainly not tested, since it's in the binary
    (we would have to have our test execute the program like we do on the command-line).
    and additional requirements could easily manifest as changes here.
    So we could easily wind up with a lot of code, including some logic,
    sitting here, untested. If we saw that this was happening, we'd probably want
    to pull this high-level nasty code into its own object (nasty because it has to
    deal with streams and loops, both of which make it much harder to work with).
    We could push it down into the cli, but that code is nice and easy to work with,
    so we wouldn't want to infect it with these dependencies unless we felt like they were really doing the same thing.
    THOUGHT
}
]

html_questions = questions.map { |question|
  begin
  q               = question.fetch :question # 'what is...'
  options         = question.fetch :options  # {a: 'abc', b: 'def'}
  answer          = question.fetch :answer   # :a
  hint            = question.fetch :hint     # 'think about such and such'
  further_thought = question.fetch :further_thought # 'lots of further thought, with newlines and such'
  rescue
    require "pry"
    binding.pry
  end
  further_thought.gsub! /^\s*/, ''
  hint.gsub!            /^\s*/, ''

  html = ""
  html << %'<div class="question">\n'
    html << "<h3>#{q}</h3>\n"
    html << "\n"

    html << "<div class='body'>\n"
      html << "<div class='options'>\n"
        options.each { |marker, text| html << "<div class='option'><div class='name'>#{marker}</div>\n<div class='value'>\n#{to_html text}\n</div></div>\n" }
      html << "</div>\n"

      html << %'<div class="hint">\n#{to_html hint}\n</div>\n' unless hint.empty?
      html << "\n"

      html << %'<div class="answer">\n<b>#{answer}</b>\n</div>\n'
      html << "\n"

      html << %'<div class="further-thought">\n#{to_html further_thought}\n</div>\n' unless further_thought.empty?
    html << "</div>\n"
  html << "</div>\n"
  html
}

html_intro = %'<div class="intro">\n#{to_html(<<MARKDOWN)}</div>'
# Quiz!

## Explanation

Go through the questions below. The purpose is not to test you, it's to allow you to test yourself.
Your goal isn't to get the answers right, it's to assimilate the knowledge in the questions. That's
why we made them, to give you another opportunity to address and think about things that we've seen
can be unclear for some students.

This is self-scored, it is for you to help push yourself along and address gaps in your knowledge.
It doesn't matter how many you get correct, it matters that you come to learn this information.

## How to take the quiz
* Look at the question, answer it in your head.
* If you need help, click the "hint" option.
* If you don't know the answer, go ahead and look at it, and then read through the further thought to help you understand
  why that is the answer. Come back in a day or two and try to go through the questions again. Your goal
  is to come to understand the answers and the reasoning behind them.
* If you do know the answer, say it to yourself in your head, then look and see that you were correct.
  Go ahead and read the "further thought" to see some of the context and nuance behind the answers that we were
  thinking about as we wrote them.
MARKDOWN

require 'sass'
stylesheet = Sass::Engine.new(<<STYLESHEET, syntax: :sass).render
.container
  padding:   3em
  position:  relative
  font-size: 1.25em

.question
  position:         relative
  background-color: #eee
  margin:           0em
  padding:          0em
  margin-bottom:    2em

  h3
    box-sizing:       border-box
    position:         relative
    padding:          0.5em
    margin:           0em
    width:            100%
    background-color: #858
    font-size:        1.5em
    font-family:      sans-serif
    color:            #fff

  .body
    padding:    1em
    border:     5px solid #858
    border-top: 0px

  .options
    .option
      margin-bottom:  0.5em
    .name
      display:        inline-block
      vertical-align: top
      font-weight:    bold
      margin-right:   0.5em
    .value
      display:        inline-block
      vertical-align: top
    p
      border: 0em
      margin: 0em

  .answer
    padding:          0.5em
    margin-bottom:    0.5em
    background-color: #afa
    font-family:      sans-serif
    font-weight:      bold
    color:            #383

  .hint
    padding:          0.5em
    margin-bottom:    0.5em
    background-color: #fc8
    font-family:      sans-serif
    font-weight:      bold
    color:            #a50

  .further-thought
    padding:          0.5em
    background-color: #aaf
    font-family:      sans-serif
    font-weight:      bold
    color:            #338
STYLESHEET

# based on http://pygments.org/_static/pygments.css
# I can't find the real docs for the styles
# http://pygments.org/docs/styles/ seems to assume you're styling in Python rather than CSS
# For my own stylesheet based on TextMate's EspressoLibre and ported to CodeRay, see /Users/josh/code/joshcheek/app/views/sass/coderay.sass
code_highlighting_stylesheet = Sass::Engine.new(<<STYLESHEET, syntax: :sass).render
pre
  background-color: #ccd
  margin:           0px
  padding:          0.75em
  .hll
    background-color: #ffffcc
  // Error
  .err
    border: 1px solid #FF0000
  .c
    color: #60a0b0
    font-style: italic  /* Comment */
  .k
    color: #007020
    font-weight: bold  /* Keyword */
  .o
    color: #666666  /* Operator */
  .cm
    color: #60a0b0
    font-style: italic  /* Comment.Multiline */
  .cp
    color: #007020  /* Comment.Preproc */
  .c1
    color: #60a0b0
    font-style: italic  /* Comment.Single */
  .cs
    color: #60a0b0
    background-color: #fff0f0  /* Comment.Special */
  .gd
    color: #A00000  /* Generic.Deleted */
  .ge
    font-style: italic  /* Generic.Emph */
  .gr
    color: #FF0000  /* Generic.Error */
  .gh
    color: #000080
    font-weight: bold  /* Generic.Heading */
  .gi
    color: #00A000  /* Generic.Inserted */
  .go
    color: #888888  /* Generic.Output */
  .gp
    color: #c65d09
    font-weight: bold  /* Generic.Prompt */
  .gs
    font-weight: bold  /* Generic.Strong */
  .gu
    color: #800080
    font-weight: bold  /* Generic.Subheading */
  .gt
    color: #0044DD  /* Generic.Traceback */
  .kc
    color: #007020
    font-weight: bold  /* Keyword.Constant */
  .kd
    color: #007020
    font-weight: bold  /* Keyword.Declaration */
  .kn
    color: #007020
    font-weight: bold  /* Keyword.Namespace */
  .kp
    color: #007020  /* Keyword.Pseudo */
  .kr
    color: #007020
    font-weight: bold  /* Keyword.Reserved */
  .kt
    color: #902000  /* Keyword.Type */
  .m
    color: #40a070  /* Literal.Number */
  .s
    color: #4070a0  /* Literal.String */
  .na
    color: #4070a0  /* Name.Attribute */
  .nb
    color: #007020  /* Name.Builtin */
  .nc
    color: #0e84b5
    font-weight: bold  /* Name.Class */
  .no
    color: #60add5  /* Name.Constant */
  .nd
    color: #555555
    font-weight: bold  /* Name.Decorator */
  .ni
    color: #d55537
    font-weight: bold  /* Name.Entity */
  .ne
    color: #007020  /* Name.Exception */
  .nf
    color: #06287e  /* Name.Function */
  .nl
    color: #002070
    font-weight: bold  /* Name.Label */
  .nn
    color: #0e84b5
    font-weight: bold  /* Name.Namespace */
  .nt
    color: #062873
    font-weight: bold  /* Name.Tag */
  .nv
    color: #bb60d5  /* Name.Variable */
  .ow
    color: #007020
    font-weight: bold  /* Operator.Word */
  .w
    color: #bbbbbb  /* Text.Whitespace */
  .mb
    color: #40a070  /* Literal.Number.Bin */
  .mf
    color: #40a070  /* Literal.Number.Float */
  .mh
    color: #40a070  /* Literal.Number.Hex */
  .mi
    color: #40a070  /* Literal.Number.Integer */
  .mo
    color: #40a070  /* Literal.Number.Oct */
  .sb
    color: #4070a0  /* Literal.String.Backtick */
  .sc
    color: #4070a0  /* Literal.String.Char */
  .sd
    color: #4070a0
    font-style: italic  /* Literal.String.Doc */
  .s2
    color: #4070a0  /* Literal.String.Double */
  .se
    color: #4070a0
    font-weight: bold  /* Literal.String.Escape */
  .sh
    color: #4070a0  /* Literal.String.Heredoc */
  .si
    color: #70a0d0
    font-style: italic  /* Literal.String.Interpol */
  .sx
    color: #c65d09  /* Literal.String.Other */
  .sr
    color: #235388  /* Literal.String.Regex */
  .s1
    color: #4070a0  /* Literal.String.Single */
  .ss
    color: #517918  /* Literal.String.Symbol */
  .bp
    color: #007020  /* Name.Builtin.Pseudo */
  .vc
    color: #bb60d5  /* Name.Variable.Class */
  .vg
    color: #bb60d5  /* Name.Variable.Global */
  .vi
    color: #bb60d5  /* Name.Variable.Instance */
  .il
    color: #40a070  /* Literal.Number.Integer.Long */
STYLESHEET

html = <<HTML
<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en">
  <head>
    <title>Google</title>
    <style type="text/css">
      #{stylesheet}
    </style>
    <style type="text/css">
      #{code_highlighting_stylesheet}
    </style>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
  </head>
  <body>
    <div class="container">
      #{to_html html_intro}
      #{html_questions.join("\n")}
    </div>

    <script>
      var Hidable = function(placeholderText, domElement) {
        this.placeholderText = placeholderText
        this.actualText      = domElement.text()
        this.domElement      = domElement
        this.hidden          = false
      }
      Hidable.prototype.toggle = function() {
        if(this.hidden) this.show()
        else            this.hide()
        return this
      }
      Hidable.prototype.hide = function() {
        this.domElement.text(this.placeholderText)
        this.hidden = true
        return this
      }
      Hidable.prototype.show = function() {
        this.domElement.text(this.actualText)
        this.hidden = false
        return this
      }

      jQuery(function() {
        var hideByClass = function(className, placeholderText) {
          jQuery(className).each(function(index, rawDomElement) {
            var domElement = jQuery(rawDomElement)
            var hidable    = new Hidable(placeholderText, domElement).toggle()
            domElement.click(function() { hidable.toggle() })
          })
        }
        hideByClass('.answer',          'See Answer')
        hideByClass('.hint',            'Hint')
        hideByClass('.further-thought', 'Going Deeper')
      })
    </script>
  </body>
</html>
HTML
run lambda { |env|
  [200, {'Content-Type' => 'text/html'}, [html]]
}


# class Wizard
# end
#
# wizard = Wizard.new 'Sarah', false
#
# What's wrong with this code? (local var examples)
#
# Class#instance_method
# Class.method
#
# What exception will be raised?
# What does this exception mean?
# What information is relevant in this exception?
#
# -----
#
# For later:
#
# { version: 1,
#   question: "How do you find the list of an object's instance variables?",
#   metadata: {},
#   options: [
#     "`object.instance_variables`"
#   ],
#   hint: '',
#   further_thought: ''
# },
