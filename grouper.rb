require 'json'

Cluster = Struct.new :rankings, :left_cluster, :right_cluster,
  :children_distance, :name
class Cluster
  def to_s(indent=0)
    if name.nil?
      s = "+\n"
      s += right_cluster.to_s(indent + 1) if right_cluster
      s += "\n"
      s += left_cluster.to_s(indent + 1) if left_cluster
      s += "\n"
      s
    else
      s = name
    end
    ("  " * indent) + s
  end
end

class PearsonCorrelation
  def similarity_score(list1, list2)
    sum1 = sum(list1)
    sum2 = sum(list2)

    sum_squares_1 = sum_squares(list1)
    sum_squares_2 = sum_squares(list2)

    sum_products = sum_products(list1, list2)

    denominator = Math.sqrt(
      (sum_squares_1 - sum1**2 / list1.length) *
      (sum_squares_2 - sum2**2 / list1.length)
    )
    return 0 if denominator == 0

    numerator = sum_products(list1, list2) - (sum1 * sum2/list1.length)
    1.0 - numerator / denominator
  end

  private

  def sum(list)
    list.inject(:+)
  end

  def sum_squares(list)
    sum(list.map { |item| item * item})
  end

  def sum_products(list1, list2)
    enum1 = list1.each
    enum2 = list2.each
    sum = 0
    loop do
      sum += enum1.next * enum2.next
    end
    sum
  end
end

class HierarchicalGrouper
  def initialize(data, algorithm=PearsonCorrelation.new)
    data = parse_data(data)
    @names = data.keys
    @columns = data.first[1].keys
    @values = []
    data.each { |k, v| @values << v.values }

    @algorithm = algorithm
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
    @distances[[cluster1, cluster2]] ||=
      @algorithm.similarity_score(cluster1.rankings, cluster2.rankings)
  end

  def build_initial_clusters
    clusters = []
    @values.each.with_index do |rankings, index|
      new_cluster = Cluster.new
      new_cluster.rankings = rankings
      new_cluster.name = @names[index]
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
    avg = []

    enum1 = cluster1.rankings.each
    enum2 = cluster2.rankings.each
    loop do
      avg << (enum1.next + enum2.next) / 2.0
    end

    avg
  end
end
