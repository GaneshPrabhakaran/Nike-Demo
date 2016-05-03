# class HomePage
#   include PageObject
#   include SiteSelector
#
#   h2  :select_location,  :class => 'lang-tunnel__header'
#
#   div :language_tunnel_africa  div_element(id: 'm-shopping-bag-image').attribute('data-bagcount')
#     else
#       page.div_element(id: 'b-shopping-bag-count')
#     end
#   end
#
#
#   def perform_hover(hover_element)
#     hover_element.hover
#   end
#
#
#
# end
#
#
#
