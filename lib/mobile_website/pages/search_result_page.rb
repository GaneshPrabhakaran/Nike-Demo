class SearchResultPage
  include PageObject
  include SiteSelector

  div     :search_content,              :id => 'exp-gridwall-wrapper'
  div     :search_controls,             :class => 'gridwall-controls'
  div     :header,                      :class => 'gateway-header'
  div     :product_count,               :class => 'product-count'
  div     :product_wall,                :class => 'exp-gridwall'
  div     :product_thumbnail_body,      :class => 'exp-product-wall'
  div     :product_thumbnail_grid,      :class => 'grid-item-content'
  div     :product_thumbnail_info,      :class => 'grid-item-info'
  div     :product_image,               :class => 'grid-item-image'
  p       :product_name,                :class => 'product-display-name'

  expected_element  :search_content

  def initialize_page
    has_expected_element?
  end

  def product_image
    product_image_element.click
  end
end