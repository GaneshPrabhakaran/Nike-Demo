module HeaderPanel
  include PageObject
  include SiteSelector

  span  :men_category,                   :xpath => "//li[contains(@class, 'gnav-bar--section')]//span[contains(text(), 'MEN')]"
  span  :women_category,                 :xpath => "//li[contains(@class, 'gnav-bar--section')]//span[contains(text(), 'WOMEN')]"
  span  :boys_category,                  :xpath => "//li[contains(@class, 'gnav-bar--section')]//span[contains(text(), 'BOYS')]"
  span  :girls_category,                 :xpath => "//li[contains(@class, 'gnav-bar--section')]//span[contains(text(), 'GIRLS')]"
  span  :customize_category,             :xpath => "//li[contains(@class, 'gnav-bar--section')]//span[contains(text(), 'CUSTOMIZE')]"
  #span  :customize_category,             :xpath => "//li[contains(@class, 'gnav-bar--section')]//span[contains(text(), 'CUSTOMIZE')]"
  span  :login_link,                     :class => "login-text"
  span  :nike_logo,                      :class => "gnav-bar--home-logo"

  #list_item (:men), {self.ul_element.list_item_element(:js_hook => 'gnav-bar--section-men')}

  def click_women
    women_category_element.click
  end

  def click_men
    men_category_element.click
  end

  def click_boys
    boys_category_element.click
  end

  def click_girls
    girls_category_element.click
  end

  def click_customize
    customize_category_element.click
  end

  def nike_logo
    nike_logo_element.click
  end
end