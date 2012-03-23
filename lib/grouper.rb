require_relative 'grouper/clustering_algorithms/hierarchical_clustering'

module Grouper
  class Grouper
    def initialize(data, algorithm=ClusteringAlgorithms::HierarchicalClustering.new)
      @algorithm = algorithm
      @algorithm.data = data
    end

    def clusters
      @algorithm.clusters
    end
  end
end
