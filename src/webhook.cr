class Webhook
  def initialize(webhook_url : String)
    @webhook_url = webhook_url
  end

  def send_update(pooky_url, hash, tohru, region)
    embed = <<-EMBED
            {
          "embeds": [
            {
              "description": "A new pooky script was detected on Supreme.",
              "color": 11256530,
              "footer": {
                "text": "Hash: #{hash} | Region: #{get_flag(region)}"
              },
              "author": {
                "name": "Blast — Monitor",
                "icon_url": "https://cdn.discordapp.com/icons/506219319030448128/342d618bf1cb75d7ce71c44a0904b437.webp"
              },
              "fields": [
                {
                  "name": "URL",
                  "value": "https:#{pooky_url}",
                  "inline": true
                },
                {
                  "name": "Tohru",
                  "value": "#{tohru.strip}",
                  "inline": true
                }
              ]
            }
          ]
        }
  EMBED

    request = Crest::Request.new(:post, @webhook_url,
      headers: {"Content-Type" => "application/json"},
      form: embed
    )
    request.execute
  end

  def get_flag(region)
    region == "us" ? "🇺🇸" : "🇬🇧"
  end
end
