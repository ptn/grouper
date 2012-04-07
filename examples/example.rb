require_relative '../lib/grouper'

grouper = Grouper::Grouper.new(File.read('examples/movies.json'))

puts
puts "Printing the list of clusters grouped by affinity:"
puts
puts "#{grouper.clusters}"

puts
puts "Printing the cluster tree:"
puts
puts grouper.cluster_tree

puts
puts "Printing the distances between every pair of nodes:"
puts
puts grouper.distances
