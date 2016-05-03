module FooterPanel
  include PageObject
  include SiteSelector

  link  :gift_cards,                 :text => 'GIFT CARDS'
  link  :find_store,                 :text => 'FIND A STORE'
  link  :sign_up_email,              :text => 'SIGN UP FOR EMAIL'
  link  :join_nike,                  :text => 'JOIN NIKE+'
  link  :get_help,                   :text => 'GET HELP'
  link  :order_status,               :text => 'Order Status'
  link  :shipping_delivery,          :text => 'Shipping and Delivery'
  link  :returns,                    :text => 'Returns'
  link  :payment_options,            :text => 'Payment Options'
  link  :contact_us,                 :text => 'Contact Us'
  link  :news,                       :text => 'NEWS'
  link  :about_nike,                 :text => 'ABOUT NIKE'
  link  :careers,                    :text => 'Careers'
  link  :investors,                  :text => 'Investors'
  link  :supply_chain,               :text => 'Supply Chain'
  link  :nike_better_world,          :text => 'Nike Better World'
  span  :twitter_link,               :class => 'nsg-glyph--twitter'
  span  :facebook_link,              :class => 'nsg-glyph--facebook'
  span  :youtube_link,               :class => 'nsg-glyph--youtube'
  span  :instagram_link,             :class => 'nsg-glyph--instagram'
end