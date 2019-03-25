require "http/client"
require "crest"
require "myhtml"
require "json"
require "./webhook.cr"

module Monitor
  @@last_pooky_val = ""
  @@webhook_url = "<ENTER DISCORD WEBHOOK URL>"

  def self.check_for_updated_pooky(old_pooky_value, region)
    p "Checking for updated pooky"
    response = HTTP::Client.get "https://www.supremenewyork.com/"
    sup_dom = Myhtml::Parser.new(response.body)
    src = ""
    hash = ""
    tohru = ""

    sup_dom.nodes(:script).each do |node|
      src = node.attribute_by("src")
      if !src.nil? && src.includes? "pooky"
        if old_pooky_value.nil? || old_pooky_value != src
          @@last_pooky_val = src
          hash = src.gsub("//assets.supremenewyork.com/assets/pooky.min.", "").gsub(".js", "")
          wh = Webhook.new @@webhook_url
          wh.send_update(src, hash, tohru, region)
        end
      end

      # Grab the tohru located from supremetohru, useful
      # for running cookie gen subroutines
      if !node.inner_text.nil? && node.inner_text.includes? "tohru"
        tohru = node.inner_text.gsub("window.supremetohru = \"", "").gsub("\";", "")
      end
    end
  end

  def self.run_monitor(region)
    spawn do
      loop do
        check_for_updated_pooky(@@last_pooky_val, region)
        # Check again in 15s
        sleep 15
      end
    end
  end
end

# You can grab this from args instead
# of hardcoding US. This doesn't control
# which site the pooky is grabbed from
# only affects the flag displayed in the
# webhook. For monitoring different regions
# set a proxy located in that region.
Monitor.run_monitor("us")
sleep
