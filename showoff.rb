require_relative 'grouper'
hc = HierarchicalGrouper.new(File.read('movies.json'))
puts hc.clusters
