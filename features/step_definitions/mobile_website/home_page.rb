Given(/^I am on mobile home page$/) do
  sleep 10
  on(HomePage)
  Log.instance.debug "User is navigated to home page"
end

When(/^I tap on Global Navigation link$/) do
  @current_page.global_navigation
  Log.instance.debug "User clicked the Global Navigation link successfully!!"
end

Then(/^I should see the Global Navigation menu displayed$/) do
  sleep 4
  expect(@current_page.navigation_panel_element).to be_visible
  Log.instance.debug "Global Navigation menu is displayed!!"
end

When(/^I search for "(.*?)"$/) do |keyword|
  on(HomePage) do |page|
    page.search_button
    sleep 5
    page.search_field = keyword
    sleep 5
    page.browser.keyboard.send_keys :return
  end
  Log.instance.debug "Searching using #{keyword} !!"
end

When(/^I tap (SHOP CHAMPS|SHOP MLB|SHOP NOW) button from home page$/) do |button|
  case button
    when "SHOP CHAMPS"
      on(HomePage).click_shop_champs
    when "SHOP MLB"
      on(HomePage).click_shop_mlb
    when "SHOP NOW"
      on(HomePage).click_shop_now
  end
  Log.instance.debug "Clicked on #{button} from home page!!"
end