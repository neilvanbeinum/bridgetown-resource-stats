# frozen_string_literal: true

require_relative "./helper"

class TestBridgetownResourceStatisticsPlugin < Bridgetown::TestCase
  def create_site(bridgetown_resource_stats_mode:)
    Bridgetown::Site.new(Bridgetown.configuration(
      "root_dir"    => root_dir,
      "source"      => source_dir,
      "destination" => dest_dir,
      "quiet"       => true,
      "bridgetown_resource_stats" => {
          mode: bridgetown_resource_stats_mode
      }
    ))
  end

  context 'when the plugin is configured with emoji mode' do
    setup do
      @site = create_site(bridgetown_resource_stats_mode: 'emoji')

      @now = Time.now

      Time.stub :now, @now do
        @site.process
      end
    end

    should "generate an SSR route that returns emoji statistics" do
      expected_contents = <<~RUBY
        class Routes::Statistics < Bridgetown::Rack::Routes
          route do |r|
            r.get "statistics" do
              {:occurences=>{"🧑‍💻"=>2, "✍️"=>1, "🗾"=>1}, :total=>4, :created_at=>"#{@now.to_s}"}
            end
          end
        end
      RUBY

      File.open(@site.in_dest_dir('server/routes/statistics.rb'), "r") do |route_file|
        assert_equal(expected_contents, route_file.read)
      end
    end
  end

  context 'when the plugin is configured with keyword mode' do
    setup do
      @site = create_site(bridgetown_resource_stats_mode: 'keyword')

      @now = Time.now

      Time.stub :now, @now do
        @site.process
      end
    end

    should "generate an SSR route containing keyword statistics" do
      expected_contents = <<~RUBY
        class Routes::Statistics < Bridgetown::Rack::Routes
          route do |r|
            r.get "statistics" do
              {:occurences=>{"ruby"=>3, "dynamic"=>1, "open source programming language"=>1, "focus"=>1, "simplicity"=>2, "productivity"=>1, "🧑‍💻"=>2, "elegant syntax"=>1, "natural"=>1, "read"=>1, "easy"=>1, "write"=>1, "✍️"=>1, "interpreted"=>1, "high"=>1, "level"=>1, "general"=>1, "purpose programming language"=>1, "supports multiple programming paradigms"=>1, "designed"=>1, "emphasis"=>1, "programming productivity"=>1, "object"=>1, "including primitive data types"=>1, "developed"=>1, "mid"=>1, "1990s"=>1, "yukihiro"=>1, "matz"=>1, "matsumoto"=>1, "japan"=>1, "🗾"=>1}, :total=>36, :created_at=>"#{ @now.to_s }"}
            end
          end
        end
      RUBY

      File.open(@site.in_dest_dir('server/routes/statistics.rb'), "r") do |route_file|
        assert_equal(expected_contents, route_file.read)
      end
    end
  end
end
