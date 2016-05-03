Given(/^I am on browser home page$/) do
  visit_page HomePage
  sleep 10
  on(HomePage)
  Log.instance.debug "User is navigated to home page"
end

When(/^I focus on the men link$/) do
  on(HomePage).perform_hover(@current_page.men_category_element)
  Log.instance.debug "User successfully hovers the men link"
end

Then(/^I should see the corresponding subnavigation container$/) do
  sleep 3
  expect(@current_page.shop_list_element).to be_visible
  Log.instance.debug "Pop up is displayed as expected!!"
end

When(/^I tap "(.*?)" in the header$/) do |category|
  case category
    when "MEN"
      on(HomePage).click_men
    when "WOMEN"
      on(HomePage).click_women
    when "BOYS"
      on(HomePage).click_boys
    when "GIRLS"
      on(HomePage).click_girls
    when "CUSTOMIZE"
      on(HomePage).click_customize
  end
  Log.instance.debug "The header #{category} is clicked!!"
end

Then(/^I should see the URL and header corresponding to "(.*?)"$/) do |category|
  sleep 5
  on(CategorySplash)
  @yaml_hash = YAML.load(File.open("config/data/url.yml", 'r'))
  urls = @yaml_hash['urls']
  @expected_url = urls[category]
  expect(@browser.current_url).to include @expected_url
  expect(@current_page.category_title).to include category
  Log.instance.debug "The URL and image #{category} is displayed!!"
end

When(/^I tap on the shop now link$/) do
  if @current_page.button_shop_now_element.visible?
    @current_page.click_shop_now
  else
    @current_page.click_shop_all_nike_pro
  end
  Log.instance.debug "Shop now link is clicked!!"
end

Given(/^I should see the (.*?) text of image in the page$/) do |expected_sub_title|
  sleep 2
  sub_titles=@current_page.get_sub_titles
  actual_sub_title= sub_titles.reject {|s| s.empty? }
  expect(actual_sub_title[0].gsub(/\n\w*/,'')).to eql expected_sub_title
  Log.instance.debug "The text #{expected_sub_title} is displayed in the page!!"
end

Then(/^I should see the content displayed in image in home page$/) do
  subtitle_contents = []
  sleep 5
  carousel_slide_count = @current_page.carousel_slides_elements.count
  carousel_slide_count.times do
    sub_titles=@current_page.get_sub_titles
    actual_sub_title = sub_titles.reject { |s| s.empty? }
    @current_page.prev_button
    subtitle_contents << actual_sub_title[0]
    sleep 5
  end
  Log.instance.debug "The contents #{subtitle_contents} are displayed in home page!!"
end

When(/^I tap on the (nike logo|left arrow)$/) do |element|
  case element
    when 'nike logo'
      on(HomePage).nike_logo
    when 'left arrow'
      on(HomePage).prev_button
  end
  Log.instance.debug "User tapped on the #{element} link!!"
end
