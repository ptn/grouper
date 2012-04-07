module Grouper
  class Cluster
    attr_accessor :rankings, :left_cluster, :right_cluster,
      :children_distance, :name

    def initialize(rankings=nil, left_cluster=nil, right_cluster=nil,
                   children_distance=nil, name=nil)
      @rankings = rankings
      @left_cluster = left_cluster
      @right_cluster = right_cluster
      @children_distance = children_distance
      @name = name
    end

    def all_names
      names = @name ? [@name] : []
      names += @left_cluster.all_names if @left_cluster
      names += @right_cluster.all_names if @right_cluster
      names
    end

    def to_s(indent=0)
      if name.nil?
        s = "\n"
        s += right_cluster.to_s(indent + 1) if right_cluster
        s += "\n"
        s += left_cluster.to_s(indent + 1) if left_cluster
        s += "\n"
        s
      else
        s = name
      end
      ("  " * indent) + "(#{indent.to_s})" + s
    end
  end
end
