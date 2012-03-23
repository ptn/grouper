module Grouper

  Cluster = Struct.new :rankings, :left_cluster, :right_cluster,
    :children_distance, :name

  class Cluster
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
