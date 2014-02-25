Spree::OrderContents.class_eval do

  # Get current line item for variant if exists
  # Add variant qty to line_item
  def add(variant, quantity = 1, currency = nil, shipment = nil)
    # If variant is a gift card we say order doesn't already contain it so that each gift card is it's own line item.
    if variant.product.is_gift_card?
      line_item = nil
    else
      line_item = grab_line_item_by_variant(variant)
    end
    add_to_line_item(variant, quantity, currency, shipment, line_item)
  end

  def add_to_line_item(variant, quantity, currency=nil, shipment=nil, line_item=nil)
    line_item ||= grab_line_item_by_variant(variant)

    if line_item
      line_item.target_shipment = shipment
      line_item.quantity += quantity.to_i
      line_item.currency = currency unless currency.nil?
    else
      line_item = order.line_items.new(quantity: quantity, variant: variant)
      line_item.target_shipment = shipment
      if currency
        line_item.currency = currency
        line_item.price    = variant.price_in(currency).amount
      else
        line_item.price    = variant.price
      end
    end

    line_item.save
    line_item
  end

end
