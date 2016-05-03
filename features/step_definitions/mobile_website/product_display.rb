When(/^I store the particular product name and I tap on it in mobile$/) do
  @expected_title=@current_page.product_name_element.text
  @current_page.product_image
  Log.instance.debug "Product name is clicked successfully!!"
end

Then(/^I should navigate to corresponding PDP page with that product name in mobile$/) do
  actual_title=on(PdpPage).product_name
  expect(actual_title).to include @expected_title.upcase
  Log.instance.debug "User is navigated to PDP page with product name in mobile!!"
end