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
  response = HTTP::Client.get "https://ask.fm/#{user}"
  abort response.status_message unless response.status_code == 200

  xpath_items    = "//div[@class='item streamItem streamItem-answer']"
  xpath_url      = "div[@class='streamItemContent streamItemContent-footer']/a/@href"
  xpath_question = "h1[@class='streamItemContent streamItemContent-question']"
  xpath_answer   = "p[@class='streamItemContent streamItemContent-answer']"

  XML.parse(response.body).xpath_nodes(xpath_items).each do |item|
    url      = "https://ask.fm#{item.xpath_node(xpath_url).text.try &.strip}"
    question = item.xpath_node(xpath_question).text.try &.strip
    answer   = item.xpath_node(xpath_answer).text.try &.strip.gsub(/質問ではない。?|不?自由/){|m| m.colorize.green}
    abort "Parse failed." unless url && question && answer

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
