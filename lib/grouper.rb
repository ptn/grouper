require_relative 'grouper/algorithms/clustering/hierarchical_clustering'

module Grouper
  class Grouper
    def initialize(data=nil,
                   algorithm=ClusteringAlgorithms::HierarchicalClustering.new(data))
      @algorithm = algorithm
    end

    def cluster_tree
      @algorithm.cluster_tree
    end

    def clusters
      @algorithm.clusters
    end

    def distances
      @algorithm.distances
    end
  end
end
