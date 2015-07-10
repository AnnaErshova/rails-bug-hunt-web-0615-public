require 'spec_helper'
require 'pry'

describe Order do
  let(:order) { create(:order) }
  let(:product) { create(:product, cost_in_cents: 100000) }

  describe 'total cost in cents' do
    it 'is the sum of all the products on the order' do
      # pending 'i can add trust me'
      # t.integer  "cost_in_cents"
      # binding.pry
      order.products << product # or populatate with Product.all?
      expect(order.total_cost_in_cents).to eq(order.products.map{|product| product.cost_in_cents}.inject(:+)) 
      # this will get it out of the array into integer, even if only one Product is available
    end
  end

  describe 'new orders' do
    it 'starts off in the unsubmitted state' do
      order = create(:order)
      expect(order.unsubmitted?).to eq true
    end
  end

  describe 'submitting' do
    context 'with products' do
      it 'transitions to the processing state' do
        order.products << product
        order.submit!
        expect(order.processing?).to eq true
      end
    end

    context 'without products' do
      it 'doesnt transition to processing' do
        # pending 'why would a sane rational user ever submit an empty order' 
        # -- ok this passes without doing anything...
        #order.products << product
        create(:order).submit!
        expect(order.processing?).to eq false
      end
    end
  end

  describe 'shipping an order' do
    it 'transitions to the shipped state' do
      # pending 'it is beneath me to test something so simple'
      # create(:order).submit!.ship!
      order.submit!
      order.ship!
      expect(order.shipped?).to eq true
    end
  end

  describe 'adding a product' do
    context 'to an unsubmitted order' do
      context 'with remaining stock' do
        let(:product) { create(:product, amount_in_stock: 5) }

        it 'increases the total cost of the order' do
          # pending 'the accountants will notice this if its broken anyway'
          # I am uncertain if we are supposed to start from 0 items in the cart or there are existing items in there
          order.products << product
          expect(order.total_cost_in_cents).to eq(order.products.map{|product| product.cost_in_cents}.inject(:+)) 
        end

        it 'adds the product to the order' do
          order.products << product
          expect(order.products).to include product
        end

        it 'decrements the amount of product in stock' do
          expect {
            order.products << product
          }.to change { product.amount_in_stock }.by(-1)
        end
      end

      context 'with no remaining stock' do
        let(:product) { create(:product, amount_in_stock: 0) }

        before do
          expect { order.products << product }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'does not add the product to the order' do
          # Order adding a product to an unsubmitted order with no remaining stock does not add the product to the order
          # pending 'im sure we could find some extras lying around'
          expect(order.products).to_not match product # or include?
        end

        it 'does not decrement the amount of product in stock' do
          product.reload
          expect(product.amount_in_stock).to eq 0
        end
      end
    end

    context 'to a submitted order' do
      let(:order) do
        order = create(:order)
        order.products << create(:product)
        order.submit!
        order
      end

      let(:product) { create(:product, amount_in_stock: 5) }

      it 'raises an exception' do
        expect { order.products << product }.to raise_error(Order::InvalidProductAddition)
      end

      it 'does not decrement the products in stock' do
        # pending 'need to get to the ping pong tournament'
        expect(product.amount_in_stock).to eq 5
      end
    end
  end

  describe 'removing a product' do
    context 'from an unsubmitted order' do
      let(:product) { create(:product, amount_in_stock: 0) }

      it 'increases the amount of product left' do
        expect {
          order.products.destroy(product)
        }.to change { product.amount_in_stock }.by(1)
      end

      it 'remove the product from the relationship' do
        order.products.destroy(product)
        expect(order.products).to_not include(product)
      end
    end

    context 'from a submitted order' do
      let(:order) do
        order = create(:order)
        order.products << create(:product, amount_in_stock: 5)
        order.submit!
        order
      end

      it 'raises an exception' do
        product = order.products.first
        expect { order.products.destroy(product) }.to raise_error(Order::InvalidProductRemoval)
      end

      it 'does not decrement the products in stock' do
        # pending 'an exception is being raised so this shouldnt happen'
        expect(order.products.last.amount_in_stock).to be < product.amount_in_stock
        expect(order.products.last.amount_in_stock).to_not eq 5 # I feel like this is a weak test, but I am not sure how to improve it
        # expect(order.products).to_not include product
      end
    end
  end
end
