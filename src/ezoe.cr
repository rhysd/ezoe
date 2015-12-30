require "colorize"
require "option_parser"
require "http/client"
require "xml/xml"

# Note:
# I can add type annotations like below:
#
#   def show_questions(user : String) : Nil
#
def show_questions(user)
  response = HTTP::Client.get "http://ask.fm/feed/profile/#{user}.rss"
  abort response.status_message unless response.status_code == 200

  XML.parse(response.body).content.try &.split(/\n\s+\n/)[2..-1].each do |item|
    question,answer,time,url = item.split('\n').map(&.strip) # &. is to_proc operator: http://crystal-lang.org/2013/09/15/to-proc.html
    answer = answer.gsub(/質問ではない。?|不?自由/){|m| m.colorize.green}
    puts "#{url}\n  #{question.colorize.red}\n  #{answer.colorize.white}\n\n"
  end
end

def post_question(user, question)
  response = HTTP::Client.get "http://ask.fm/#{user}"

  # XXX: Dirty because Crystal doesn't have HTML parser yet
  token = response.body.match(/<input name="authenticity_token" type="hidden" value="([^"]+)"/).try &.[1]
  abort "authentication token not found" unless token

  params = HTTP::Params.build do |form|
    form.add "authenticity_token", token
    form.add "question[question_text]", question
    form.add "question[force_anonymous]", "force_anonymous"
  end

  response = HTTP::Client.post(
      "http://ask.fm/#{user}/questions/create?#{params}",
      HTTP::Headers{"Referer": "http://ask.fm/#{user}"}, # Hash-like types: http://crystal-lang.org/docs/syntax_and_semantics/literals/hash.html
    )
  abort response.status_message unless response.status_code == 200
end

user = "EzoeRyou"
begin
  OptionParser.parse(ARGV) do |parser|
    parser.banner = "Usage: ezoe [-u {user}] [{question}]"

    parser.on("-u USER", "--user", "who do you want to ask to?") do |u|
      user = u
    end

    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit 0
    end
  end
rescue e : OptionParser::InvalidOption
  abort e.message
end

if ARGV.empty?
  show_questions(user)
else
  post_question(user, ARGV.first)
end
