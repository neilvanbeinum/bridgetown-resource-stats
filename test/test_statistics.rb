# frozen_string_literal: true

require_relative "./helper"

class TestSamplePlugin < Bridgetown::TestCase
  should "generate an SSR route containing emoji statistics when in emoji mode" do
    @site = Bridgetown::Site.new(Bridgetown.configuration(
      "root_dir"    => root_dir,
      "source"      => source_dir,
      "destination" => dest_dir,
      "quiet"       => true,
      "bridgetown_resource_stats" => {
          mode: "emoji"
      }
    ))

    @now = Time.now

    Time.stub :now, @now do
      @site.process
    end

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

  should "generate an SSR route containing keyword statistics when in keyword mode" do
    @site = Bridgetown::Site.new(Bridgetown.configuration(
      "root_dir"    => root_dir,
      "source"      => source_dir,
      "destination" => dest_dir,
      "quiet"       => true,
      "bridgetown_resource_stats" => {
          mode: "keyword"
      }
    ))

    @now = Time.now

    Time.stub :now, @now do
      @site.process
    end

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
