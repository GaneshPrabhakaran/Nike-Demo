Then(/^I should see the search results page$/) do
  sleep 5
  on(SearchResultPage)
  expect(@current_page.header_element.text).to include "RESULTS FOR"
  Log.instance.debug "Search results page is displayed successfully!!"
end
