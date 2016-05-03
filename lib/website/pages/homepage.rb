class HomePage
  include PageObject
  include SiteSelector
  include FooterPanel
  include HeaderPanel
  include CarouselPanel

  div  :shop_list,        :class => 'subnav-container'
  divs  :carousel_slides, :class => 'nike-cq-carousel-slide'

  page_url ExecutionEnvironment.url

  def perform_hover(hover_element)
    hover_element.hover
  end

end



