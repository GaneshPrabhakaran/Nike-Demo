class CategoryBrowse
  include PageObject
  include SiteSelector
  include HeaderPanel
  include FooterPanel

  div :product_thumbnail_body,        :class => 'exp-product-wall'
  div :product_thumbnail_grid,        :class => 'grid-item-content'
  div :product_thumbnail_info,        :class => 'grid-item-info'
  div :left_navigation,               :class =>'exp-left-nav-title'
  p :product_name,                       :class => 'product-display-name'

  expected_element  :product_thumbnail_body

  def initialize_page
    has_expected_element?
  end

  def product_name
    product_name_element.click
  end
end