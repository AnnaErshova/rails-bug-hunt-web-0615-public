class Order < ActiveRecord::Base
  has_many :product_orders
  has_many :products, through: :product_orders,
                before_add: :manage_product_addition!,
                before_remove: :manage_product_removal!

  include AASM

  # https://github.com/aasm/aasm
  aasm whiny_transitions: false do
    state :unsubmitted, initial: true
    state :processing
    state :shipped

    event :submit do
      transitions from: :unsubmitted, to: :processing, guards: [:has_products?]
    end

    event :ship do
      transitions from: :processing, to: :shipped
    end
  end

  def total_cost_in_cents
    products.sum(:cost_in_cents)
  end

  def manage_product_addition!(product)
    product.decrement_amount_in_stock!
    raise InvalidProductAddition unless self.unsubmitted?
  end

  def manage_product_removal!(product)
    product.increment_amount_in_stock! 
    raise InvalidProductRemoval unless self.unsubmitted?
  end

  def has_products?
    self.products.count >= 0
  end

  class InvalidProductAddition < StandardError
  end

  class InvalidProductRemoval < StandardError
  end
end
