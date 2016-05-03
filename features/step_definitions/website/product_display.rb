When(/^I store the particular product name and I tap on it$/) do
  @expected_title=@current_page.product_name_element.text
  @current_page.product_name
  Log.instance.debug "Product is clicked from PDP page"
end

Then(/^I should navigate to corresponding PDP page with that product name$/) do
  actual_title=on(PdpPage).product
  expect(actual_title).to eql @expected_title.upcase
  Log.instance.debug "User is navigated to the PDP page!!"
end
