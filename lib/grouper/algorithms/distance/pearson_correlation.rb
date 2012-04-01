module Grouper
  module DistanceAlgorithms

    class PearsonCorrelation
      def distance(list1, list2)
        1.0 - correlation(list1, list2)
      end

      def correlation(list1, list2)
        sum1 = sum(list1)
        sum2 = sum(list2)

        sum_squares_1 = sum_squares(list1)
        sum_squares_2 = sum_squares(list2)

        denominator = Math.sqrt(
          (sum_squares_1 - sum1**2 / list1.length.to_f) *
          (sum_squares_2 - sum2**2 / list1.length.to_f)
        )

        return 0.0 if denominator == 0

        sum_products = sum_products(list1, list2)
        numerator = sum_products(list1, list2) - (sum1 * sum2/list1.length)
        numerator / denominator
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

  end
end
