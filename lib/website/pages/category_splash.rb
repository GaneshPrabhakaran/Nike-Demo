class CategorySplash
  include PageObject
  include SiteSelector
  include CarouselPanel


  span :button_shop_now,                    :xpath => "//div[contains(@class, 'nike-cq-cta')]//span[contains(text(), 'SHOP NOW')]"
  span :button_explore_cold_weather,        :xpath => "//div[contains(@class, 'nike-cq-cta')]//span[contains(text(), 'EXPLORE COLD WEATHER')]"
  span :category_title,                     :class => 'nike-cq-nav-title-wrapped'
  span :button_shop_all_nike,               :xpath => "//div[contains(@class, 'nike-cq-cta')]//span[contains(text(), 'SHOP ALL NIKE PRO')]"

  expected_element  :button_shop_now

  def initialize_page
    has_expected_element?
  end

  def click_shop_now
    button_shop_now_element.click
  end

  def click_shop_all_nike_pro
    button_shop_all_nike_element.click
  end
end