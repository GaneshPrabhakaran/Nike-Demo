class CategoryBrowse
  include PageObject
  include SiteSelector
  include HeaderPanel
  include FooterPanel

  div         :product_thumbnail_body,        :class => 'exp-product-wall'
  div         :product_thumbnail_grid,        :class => 'grid-item-content'
  div         :product_thumbnail_info,        :class => 'grid-item-info'
  p           :product_name,                  :class => 'product-display-name'
  div         :product_image,                 :class => 'grid-item-image'

  expected_element  :product_thumbnail_body

  def initialize_page
    has_expected_element?
  end

  def product_name
    product_name_element.click
  end

  def product_image
    product_image_element.click
  end
end