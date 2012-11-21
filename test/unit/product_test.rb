require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  # test "the truth" do
  #   assert true
  # end
  #
  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = Product.new(title: "My book title",
                          description: "1234567890",
                          image_url: "zzz.jpg")
    product.price=-1
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')
    product.price=0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')
    product.price=1
    assert product.valid?
  end

  def new_product(image_url)
     Product.new(title: "My book title",
                 description: "1234567890",
                 price: 1,
                 image_url: image_url)
  end

  test "image url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.jpg Fred.Jpg http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end
    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end

  test "product is not valid without a unique title" do
    product = Product.new( title: products(:ruby).title,
                          description: "1234567890",
                          price: 1,
                          image_url: "fred.gif")
    assert !product.save
#   assert_equal "has already been taken", product.errors[:title].join('; ')
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
      product.errors[:title].join('; ')
  end

  test "product title must be at least 10 characters long" do
    product = Product.new(description: products(:ruby).description,
                          price: products(:ruby).price,
                          image_url: products(:ruby).image_url)
    product.title = "123456789" #9 characters title, should be at least 10
    assert product.invalid?
    product.title = "1234567890" #10 characters title, should be valid
    assert product.valid?
  end

  test "product description must be at least 10 characters long" do
    product = Product.new(title: '1234567890',
                          price: products(:ruby).price,
                          image_url: products(:ruby).image_url)
    product.description = "123456789" #9 characters title, should be at least 10
    assert product.invalid?, "#{product.description} is a too short description and should be not valid"
    product.description = "1234567890" #10 characters title, should be valid
    assert product.valid?, "#{product.description} should be a valid description. #{product.errors.inspect}"

  end
end
