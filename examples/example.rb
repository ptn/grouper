require_relative '../lib/grouper'

grouper = Grouper::Grouper.new(File.read('examples/movies.json'))
puts grouper.clusters
