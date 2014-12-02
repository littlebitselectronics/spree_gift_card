require_dependency 'spree/calculator'

module Spree
  class Calculator < ActiveRecord::Base
    class GiftCard < Calculator

      def self.description
        Spree.t(:gift_card_calculator)
      end

      def compute(order, gift_card)
        # Ensure a negative amount which does not exceed the sum of the order's item_total, ship_total, and
        # tax_total, minus other credits.
        current = order.adjustments.select{|a| a.source.try(:code) == gift_card.code}.first
        return current.try(:amount) unless current.nil?
        credits = order.adjustments.select{|a|a.amount < 0 && a.source_type != 'Spree::GiftCard' && a.source_type != 'Spree::PromotionAction'}.map(&:amount).sum
        credits_no_tax = order.adjustments.select{|a|a.amount < 0 && a.source_type != 'Spree::Tax'}.map(&:amount).sum
        [(order.item_total + order.ship_total + order.tax_total + credits + credits_no_tax), gift_card.current_value].min * -1
      end

    end
  end
end
