# Allow the site methods to be used everywhere
Object.class_eval do
  include SiteSelector
end
