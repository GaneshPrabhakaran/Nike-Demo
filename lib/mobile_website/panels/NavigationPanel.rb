module NavigationPanel
  include PageObject
  include SiteSelector

  div     :content,             :class => 'exp-panel__body'
  div     :navigation_panel,    :class => 'exp-panel__body-content'
  span    :arrow_button,        :class => 'nav-panel__btn-arrow'
  button  :men,                 :class => 'nav-panel--is-men'
  button  :women,               :class => 'nav-panel--is-women'
  button  :men,                 :class => 'nav-panel--is-boys'
  button  :women,               :class => 'nav-panel--is-girls'

end