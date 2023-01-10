# frozen_string_literal: true

require 'emoji_regex'
require 'nokogiri'
require 'rake_text'

module Statistician
  class Builder < Bridgetown::Builder
    def build
      Bridgetown::Hooks.register_one :site, :post_write, reloadable: false do |site|
        statistics = { occurences: Hash.new(0) }

        if config[:bridgetown_resource_stats][:mode] == "emoji"
          site.resources.each do |resource|
            doc = Nokogiri.HTML5(resource.output)

            emojis = doc.to_s.scan EmojiRegex::Regex

            emojis.each do |emoji|
              statistics[:occurences][emoji] += 1
            end
          end
        elsif config[:bridgetown_resource_stats][:mode] == "keyword"
          rake_text = RakeText.new
          stoplist = rake_text.send(:buildStopwordRegExPattern, RakeText.SMART)

          site.resources.each do |resource|
            doc = Nokogiri.HTML5(resource.output)

            body = doc.at_css('body')

            # TODO: Parameterise the ignored elements here
            main_elements = body.elements.reject { |e| ['nav', 'footer'].include?(e.name)  }

            main_elements.each do |element|
              lines = element.text.each_line.reject { |line| line.strip.empty? }

              lines.each do |line|
                keywords = rake_text.send(:generateCandidateKeywords, line.split(/[[[:punct:]].!?{}`,;:\t\\-\\"\\(\\)\\\'\u2019\u2013]/u), stoplist)

                keywords.each do |word|
                  statistics[:occurences][word] += 1
                end
              end
            end
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

Statistician::Builder.register
