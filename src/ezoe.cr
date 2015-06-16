require "colorize"
require "option_parser"
require "http/client"
require "xml/xml"
require "cgi"

def error(msg)
  STDERR.puts msg
  exit 1
end

def show_questions(user)
  response = HTTP::Client.get "http://ask.fm/feed/profile/#{user}.rss"
  error response.status_message unless response.status_code == 200

  XML.parse(response.body).content.try &.split(/\n\s+\n/)[2..-1].each do |item|
    question,answer,time,url = item.split('\n').map(&.strip)
    answer = answer.gsub(/質問ではない。?|不?自由/){|m| m.colorize.green}
    puts "#{url}\n  #{question.colorize.red}\n  #{answer.colorize.white}\n\n"
  end
end

def post_question(user, question)
  response = HTTP::Client.get "http://ask.fm/#{user}"

  # XXX: Dirty because Crystal doesn't have HTML parser yet
  token = response.body.match(/<input name="authenticity_token" type="hidden" value="([^"]+)"/).try &.[1]
  error "authentication token not found" unless token

  params = CGI.build_form do |form|
    form.add "authenticity_token", token
    form.add "question[question_text]", question
    form.add "question[force_anonymous]", "force_anonymous",
  end

  response = HTTP::Client.post(
      "http://ask.fm/#{user}/questions/create?#{params}",
      HTTP::Headers.new.add("Referer", "http://ask.fm/#{user}")
    )
  error response.status_message unless response.status_code == 200
end

user = "EzoeRyou"
OptionParser.parse(ARGV) do |parser|
  parser.on("-u USER", "who do you want to ask to?") do |u|
    user = u
  end
end

if ARGV.empty?
  show_questions(user)
else
  post_question(user, ARGV.first)
end
