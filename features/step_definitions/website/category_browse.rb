Then(/^I see category browse page with filter option$/) do
  expect(on(CategoryBrowse).left_navigation_element).to be_visible
  Log.instance.debug "Category browse page is displayed with filter option"
end
