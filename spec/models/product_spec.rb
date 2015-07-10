require 'spec_helper'

describe Product do
  describe 'in stock products' do
    it 'retrieves all products with stock greater than 0' do
      # pending 'deadline in 5 minutes crap crap crap'
      product1 = create(:product, amount_in_stock: 0)
      product2 = create(:product, amount_in_stock: 1)
      product3 = create(:product, amount_in_stock: 0)

      expect(Product.in_stock).to match_array([product2])
    end
  end

  describe 'out of stock products' do
    it 'retrieves all products with a stock of 0' do
      product1 = create(:product, amount_in_stock: 0)
      product2 = create(:product, amount_in_stock: 1)
      product3 = create(:product, amount_in_stock: 0)

      expect(Product.out_of_stock).to match_array([product1, product3])
    end
  end

  describe 'decrementing the amount in stock' do
    it 'decreases the amount in stock by 1' do
      product = build(:product, amount_in_stock: 5)
      expect {
        product.decrement_amount_in_stock!
      }.to change { product.amount_in_stock }.by(-1)
    end

    it 'raises an exception if theres no remaining product' do
        product = build(:product, amount_in_stock: 0) # build a product where there is no stock left
        expect{
          product.decrement_amount_in_stock!
        }.to raise_error
      # pending 'does anyone use these tests for anything anyway?'
    end
  end

  describe 'incrementing the amount in stock' do
    let(:product) { create(:product, amount_in_stock: 1) }

    it 'increases the amount in stock by 1' do
      expect {
        product.increment_amount_in_stock!
      }.to change { product.amount_in_stock }.by(1)
    end
  end
end
