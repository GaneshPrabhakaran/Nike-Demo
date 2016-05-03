module HeaderPanel
  include PageObject
  include SiteSelector

  span        :login_link,                     :class => "login-text"
  span        :nike_logo,                      :class => "gnav-bar--home-logo"
  span        :global_navigation,              :class => 'nsg-glyph--menu'
  span        :search_button,                  :class => 'nsg-glyph--search'
  text_field  :search_field,                   :class => 'search-field'

  #list_item (:men), {self.ul_element.list_item_element(:js_hook => 'gnav-bar--section-men')}

  def global_navigation
    global_navigation_element.click
  end

  def search_button
    search_button_element.click
  end

end