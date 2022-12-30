# frozen_string_literal: true

require_relative "./helper"

class TestSamplePlugin < Bridgetown::TestCase
  def setup
    @site = Bridgetown::Site.new(Bridgetown.configuration(
                                   "root_dir"    => root_dir,
                                   "source"      => source_dir,
                                   "destination" => dest_dir,
                                   "quiet"       => true
                                 ))
  end

  context "statistics" do
    setup do
      @now = Time.now

      Time.stub :now, @now do
        with_metadata title: "My Ruby Site" do
          @site.process
        end
      end
    end

    should "generate an SSR route containing statistics on resource contents" do
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
end
