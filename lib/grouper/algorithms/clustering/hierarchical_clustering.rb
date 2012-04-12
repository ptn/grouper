require 'json'

require_relative '../../algorithms/distance/pearson_correlation'
require_relative '../../rankings'
require_relative '../../cluster'

module Grouper
  module ClusteringAlgorithms

    WrongInputFormat = Class.new(Exception)

    class HierarchicalClustering
      attr_reader :data

      def initialize(data, algorithm=DistanceAlgorithms::PearsonCorrelation.new)
        @data = parse_data(data)
        @algorithm = algorithm
      end

      # Builds a binary tree that groups nodes into clusters two at a
      # time according to their distance.
      #
      # Returns a Cluster object that represents the top of the tree.
      def cluster_tree
        @cluster_tree ||= build_cluster_tree
      end

      # Builds a list of lists, each of which contains all of the
      # clusters that belong to that affinity level.
      #
      # Example
      #
      #   hierarchical_clustering.clusters
      #   # =>
      #   [
      #     # highest affinity (0)
      #     [
      #       ["Movie 3"], ["Movie 2"], ["Movie 5"],
      #       ["Movie 4"], ["Movie 6"], ["Movie 1"]
      #     ],
      #     # affinity 1
      #     [
      #       ["Movie 3"], ["Movie 2"],
      #       ["Movie 4", "Movie 5"],
      #       ["Movie 1", "Movie 6"]
      #     ],
      #     # affinity 2
      #     [
      #       ["Movie 2", "Movie 3"],
      #       ["Movie 1", "Movie 6", "Movie 4", "Movie 5"]
      #     ],
      #     # affinity 3 (lowest in this example; the lowest affinity
      #       always has only one cluster)
      #     [
      #       ["Movie 1", "Movie 6", "Movie 4", "Movie 5", "Movie 2", "Movie 3"]
      #     ]
      #   ]
      def clusters
        @clusters ||= build_clusters
      end

      # Calculates the distance between every two pair of items.
      #
      # Returns a Hash whose keys are pairs of items and the
      # corresponding value is the distance between them.
      #
      # Example
      #
      #   hierarchical_clustering.distances
      #   # => {["Movie 1", "Movie 2"]=>1.0,
      #         ["Movie 1", "Movie 3"]=>1.8571428571428572,
      #         ["Movie 1", "Movie 4"]=>0.02235922769821508,
      #         ["Movie 1", "Movie 5"]=>0.019684381936760587,
      #         ["Movie 1", "Movie 6"]=>0.0,
      #         ( ... ad nauseum...)
      #         ["Movie 2", "Movie 6"]=>1.0,
      #         ["Movie 3", "Movie 4"]=>2.0,
      #         ["Movie 4", "Movie 5"]=>8.607703910912257e-05,
      #         ["Movie 5", "Movie 6"]=>0.0}
      def distances
        distances = {}
        clusters = build_initial_clusters

        clusters.each.with_index do |cluster1, index1|
          clusters[(index1 + 1)..-1].each.with_index do |cluster2, index2|
            distances[[cluster1.name, cluster2.name]] = distance(cluster1, cluster2)
          end
        end

        distances
      end

      private

      def parse_data(json)
        JSON.parse(json)
      rescue Exception => ex
        raise WrongInputFormat, "Wrong Data format: #{ex.message}" 
      end

      def build_cluster_tree
        clusters = build_initial_clusters

        while clusters.length > 1 do
          cluster1, cluster2, distance = find_closest_clusters(clusters)

          rankings_avg = average_rankings(cluster1, cluster2)
          new_cluster = Cluster.new(rankings_avg, cluster1, cluster2, distance)

          clusters.delete(cluster1)
          clusters.delete(cluster2)
          clusters.push(new_cluster)
        end

        clusters[0]
      end

      def distance(cluster1, cluster2)
        @distances ||= {}
        unless @distances[[cluster1, cluster2]]
          commons = cluster1.rankings.commons(cluster2.rankings)
          common_rankings1 = commons.map { |k, v| v[0] }
          common_rankings2 = commons.map { |k, v| v[1] }
          score = @algorithm.distance(common_rankings1, common_rankings2)
          @distances[[cluster1, cluster2]] = score
        end

        @distances[[cluster1, cluster2]]
      end

      def build_initial_clusters
        clusters = []
        @data.each do |name, rankings|
          new_cluster = Cluster.new
          new_cluster.rankings = Rankings.new(rankings)
          new_cluster.name = name
          clusters << new_cluster
        end

        clusters
      end

      def find_closest_clusters(clusters)
        closest1_index = 0
        closest2_index = 1
        shortest_distance = distance(clusters[closest1_index],
                                     clusters[closest2_index]) 

        clusters.each.with_index do |cluster1, index1|
          clusters[(index1 + 1)..-1].each.with_index do |cluster2, index2|
            distance = distance(cluster1, cluster2)
            if distance < shortest_distance
              shortest_distance = distance
              closest1_index = index1
              closest2_index = index1 + 1 + index2
            end
          end
        end

        [clusters[closest1_index], clusters[closest2_index], shortest_distance]
      end

      def average_rankings(cluster1, cluster2)
        avg = {}

        cluster1.rankings.each do |k, v|
          avg[k] = (v + cluster2.rankings[k].to_f) / 2.0
        end

        Rankings.new(avg)
      end

      # Recurses the cluster tree several times, each time going down
      # one level less than before, aggregating nodes into clusters.
      def build_clusters
        @clusters = []
        max_level = -1

        while max_level != 0
          clusters, max_depth = build_clusters_up_to_level(max_level)
          @clusters << clusters
          max_level = max_depth - 1
        end

        @clusters << [cluster_tree.all_names]
      end


      def build_clusters_up_to_level(max_level=-1, level=0,
                                     cluster=cluster_tree)
        current_clusters = []
        max_depth = level

        if max_level == -1 || level < max_level
          if cluster.leaf?
            current_clusters << cluster.all_names
          else
            # Recurse down to children.
            if cluster.right_cluster
              children_clusters, child_max_depth = build_clusters_up_to_level(
                                                     max_level,
                                                     level + 1,
                                                     cluster.right_cluster
                                                   )
              current_clusters += children_clusters
              max_depth = child_max_depth if child_max_depth > max_depth
            end

            if cluster.left_cluster
              children_clusters, child_max_depth = build_clusters_up_to_level(
                                                     max_level,
                                                     level + 1,
                                                     cluster.left_cluster
                                                   )
              current_clusters += children_clusters
              max_depth = child_max_depth if child_max_depth > max_depth
            end

          end
        else
          # We are no longer below max_level
          current_clusters << cluster.all_names
        end

        [current_clusters, max_depth]
      end

    end
  end
end
