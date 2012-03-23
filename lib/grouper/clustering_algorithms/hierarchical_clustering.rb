require 'json'

require_relative '../distance_algorithms/pearson_correlation'
require_relative 'rankings'
require_relative 'cluster'

module Grouper
  module ClusteringAlgorithms

    class HierarchicalClustering
      def initialize(algorithm=DistanceAlgorithms::PearsonCorrelation.new)
        @data = {}
        @algorithm = algorithm
      end

      def data=(data)
        @data = parse_data(data)
      end

      def clusters
        @clusters ||= build_clusters
      end

      private

      def parse_data(json)
        JSON.parse(json)
      rescue Exception => ex
        raise WrongInputFormat, "Wrong Data format: #{ex.message}" 
      end

      def build_clusters
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
    end

  end
end
