Spree::OrdersController.class_eval do

  Spree::PermittedAttributes.checkout_attributes << :gift_code

  def update
    if @order.contents.update_cart(order_params)
      apply_gift_code
      respond_with(@order) do |format|
        format.html do
          if params.has_key?(:checkout)
            @order.next if @order.cart?
            redirect_to checkout_state_path(@order.checkout_steps.first)
          else
            redirect_to cart_path
          end
        end
      end
    else
      respond_with(@order)
    end
  end

end
