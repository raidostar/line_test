class Notify
  require 'net/http'
  require 'uri'

  TOKEN = 'xmFj7d0G95unqtddMopRCLpeFwJ7iuso29LLXaH1q3n'
  URI = URI.parse("https://notify-api.line.me/api/notify")

  def make_request1(msg)
    request = Net::HTTP::Post.new(URI)
    request["Authorization"] = "Bearer #{TOKEN}"
    request.set_form_data({message: msg, stickerId: 2, stickerPackageId: 1})
    request
  end

  def make_request2(msg)
    request = Net::HTTP::Post.new(URI)
    request["Authorization"] = "Bearer #{TOKEN}"
    request.set_form_data({message: msg, stickerId: 525, stickerPackageId: 2})
    request
  end

  def make_request3(msg)
    request = Net::HTTP::Post.new(URI)
    request["Authorization"] = "Bearer #{TOKEN}"
    request.set_form_data({message: msg, stickerId: 22, stickerPackageId: 2})
    request
  end

  def send(obj)
    #puts (msg.include?('リリース'))
    puts (obj.class)
    if obj.class == Book
      if msg.include?('リリース')
        request = make_request1(msg)
      elsif msg.include?('終了')
        request = make_request2(msg)
      end
    else
      request = make_request3(obj.sender)
    end

    response = Net::HTTP.start(URI.hostname, URI.port, use_ssl: URI.scheme == "https") do |https|
      https.request(request)
    end
  end
end