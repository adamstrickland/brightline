# frozen_string_literal: true

module FixtureSupport
  def fixture(subpath)
    revised_subpath = if File.extname(subpath) == ""
                        "#{subpath}.json"
                      else
                        subpath
                      end

    fullpath = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", revised_subpath))

    raise unless File.exist?(fullpath)

    loader = case File.extname(fullpath)
             when /\.ya?ml/ then YAML.method(:safe_load)
             when /\.json/  then JSON.method(:parse)
             end

    raise if loader.nil?

    content = File.read(fullpath)

    loader.call(content)
  end
end
