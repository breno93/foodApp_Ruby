class Product < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 50, 50 ]
  end

  # Isso define um relacionamento de "muitos para um"
  belongs_to :category
  has_many :stocks, dependent: :destroy
  has_many :order_products
end
