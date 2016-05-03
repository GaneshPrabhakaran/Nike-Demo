class HomePage
  include PageObject
  include SiteSelector
  include HeaderPanel
  include FooterPanel
  include CarouselPanel
  include NavigationPanel

  page_url ExecutionEnvironment.url

end



