class CategorySplash
  include PageObject
  include SiteSelector

  span :button_shop_now,               :xpath => "//div[contains(@class, 'nike-cq-cta')]//span[contains(text(), 'SHOP NOW')]"
  span :button_explore_cold_weather,   :xpath => "//div[contains(@class, 'nike-cq-cta')]//span[contains(text(), 'EXPLORE COLD WEATHER')]"

  expected_element  :button_shop_now

  def initialize_page
    has_expected_element?
  end

  def click_shop_now
    button_shop_now_element.click
  end
end