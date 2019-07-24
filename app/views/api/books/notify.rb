class Notify
  TOKEN = 'xmFj7d0G95unqtddMopRCLpeFwJ7iuso29LLXaH1q3n'
  URI = URI.parse("https://notify-api.line.me/api/notify")

  def make_request(msg)
    request = Net::HTTP::Post.new(URI)
    request["Authorization"] = "Bearer #{TOKEN}"
    request.set_form_data(message: msg)
    request
  end

  def add_sticker
    request = Net::HTTP::Post.new(URI)
    request["Authorization"] = "Bearer #{TOKEN}"
    request.set_form_data(message: msg)
    request
  end

  def send(msg)
    request = make_request(msg)
    response = Net::HTTP.start(URI.hostname, URI.port, use_ssl: URI.scheme == "https") do |https|
      https.request(request)
    end
  end
end