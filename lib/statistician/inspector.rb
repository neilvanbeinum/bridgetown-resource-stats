# frozen_string_literal: true

require 'emoji_regex'
require 'nokogiri'

module Statistician
  class Inspector < Bridgetown::Builder
    def build
      Bridgetown::Hooks.register_one :site, :post_write, reloadable: false do |site|
        statistics = { occurences: Hash.new(0) }

        site.resources.each do |resource|
          doc = Nokogiri.HTML5(resource.output)

          emojis = doc.to_s.scan EmojiRegex::Regex

          emojis.each do |emoji|
            statistics[:occurences][emoji] += 1
          end
        end

        statistics[:total] = statistics[:occurences].values.sum
        statistics[:created_at] = Time.now.to_s

        FileUtils.mkdir_p(site.in_dest_dir('server/routes'))

        File.write(
          site.in_dest_dir("server/routes/statistics.rb"),
          create_statistics_route_file(statistics),
          mode: "w"
        )
      end
    end

    private

    def create_statistics_route_file(statistics)
      <<~RUBY
        class Routes::Statistics < Bridgetown::Rack::Routes
          route do |r|
            r.get "statistics" do
              #{ statistics }
            end
          end
        end
      RUBY
    end
  end
end

Statistician::Inspector.register
