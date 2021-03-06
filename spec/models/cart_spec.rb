require 'rails_helper'

RSpec.describe Cart do
  describe 'Instance Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 2 )
      @simba = @megan.items.create!(name: 'Simba', description: "I'm Simba!", price: 30, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
      @discount1 = @megan.discounts.create!(name: "50% off 3 or more items!", item_amount: 3, discount_percentage: 50)
      @discount2 = @megan.discounts.create!(name: "75% off 5 or more items!", item_amount: 5, discount_percentage: 75)
    end

    it '.contents' do
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.add_item()' do
      @cart.add_item(@hippo.id.to_s)

      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2,
        @hippo.id.to_s => 1
        })
    end

    it '.count' do
      expect(@cart.count).to eq(3)
    end

    it '.items' do
      expect(@cart.items).to eq([@ogre, @giant])
    end

    it '.grand_total' do
      expect(@cart.grand_total).to eq(120)
      @cart.add_item(@ogre.id.to_s)
      @cart.add_item(@ogre.id.to_s)
      expect(@cart.grand_total).to eq(130.0)
    end

    it '.count_of()' do
      expect(@cart.count_of(@ogre.id)).to eq(1)
      expect(@cart.count_of(@giant.id)).to eq(2)
    end

    it '.subtotal_of()' do
      expect(@cart.subtotal_of(@ogre.id)).to eq(20)
      expect(@cart.subtotal_of(@giant.id)).to eq(100)
    end

    it '.limit_reached?()' do
      expect(@cart.limit_reached?(@ogre.id)).to eq(false)
      expect(@cart.limit_reached?(@giant.id)).to eq(true)
    end

    it '.less_item()' do
      @cart.less_item(@giant.id.to_s)

      expect(@cart.count_of(@giant.id)).to eq(1)
    end

    it ".maximum_discount()" do
      @cart.add_item(@simba.id.to_s)
      @cart.add_item(@simba.id.to_s)
      @cart.add_item(@simba.id.to_s)
      @cart.add_item(@simba.id.to_s)
      @cart.add_item(@simba.id.to_s)

      expect(@cart.maximum_discount(@simba.id)).to eq(75)
    end

    it ".available_discount?()" do
      @cart.add_item(@ogre.id.to_s)
      @cart.add_item(@ogre.id.to_s)
      @cart.add_item(@ogre.id.to_s)

      expect(@cart.available_discount?(@ogre.id)).to eq(true)
      expect(@cart.available_discount?(@giant.id)).to eq(false)
    end

    it ".discounted_subtotal()" do
      @cart.add_item(@ogre.id.to_s)
      @cart.add_item(@ogre.id.to_s)

      expect(@cart.discounted_subtotal(@ogre.id)).to eq(30.0)
      expect(@cart.discounted_subtotal(@giant.id)).to eq(100)
    end
  end
end
