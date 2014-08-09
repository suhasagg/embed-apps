require 'net/http'
require 'uri'

class Gist

  TOKEN = "5d1510e4b2334c507f582c3c057005af96d24271"

  def self.create(app)
    query = "/gists?access_token=#{TOKEN}"
    req = Net::HTTP::Post.new(query, initheader = {'Content-Type' => 'application/json'})
    req.body = {
      "description" => "UI Template #{app.name}",
      "public" => true,
      "files" => {
        "template_task.html" => {
          "content" => app.script
        }
      }
    }.to_json
    result = execute_request(req)
    Gist.new(result["id"].to_i)
  end

  def initialize(gist_id)
    if gist_id.nil?
      raise ArgumentError.new("Gist ID required")
    end
    @gist_id = gist_id
  end

  def url
    "https://gist.github.com/#{@gist_id}"
  end

  def script=(script)
    query = "/gists/#{@gist_id}?access_token=#{TOKEN}"
    req = Net::HTTP::Patch.new(query, initheader = {'Content-Type' => 'application/json'})
    req.body = {
      "files" => {
        "template_task.html" => {
          "content" => script
        }
      }
    }.to_json
    result = execute_request(req)
  end

  def script
    query = "/gists/#{@gist_id}?access_token=#{TOKEN}"
    req = Net::HTTP::Get.new(query)
    result = execute_request(req)
    result["files"]["template_task.html"]["content"]
  end

  def clone
    query="/gists/#{@gist_id}/fork?access_token=#{TOKEN}"
    req = Net::HTTP::Post.new(query)
    result = execute_request(req)
    p result
    Gist.new(result["id"].to_i)
  end

  protected

  def execute_request (req)
    uri = URI.parse('https://api.github.com')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
    response = http.start { |http| http.request(req) }
    JSON.parse(response.body)
  end

end
