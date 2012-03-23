module Grouper
  module DistanceAlgorithms

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

  end
end
