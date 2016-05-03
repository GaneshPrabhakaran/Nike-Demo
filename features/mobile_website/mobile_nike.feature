Feature: Verify if a user is able to view the page contents properly

  @Guest @Automated @pop_up @nikemobile
  Scenario: Verify the functionality of Global Navigation menu
    Given I am on mobile home page
    When I tap on Global Navigation link
    Then I should see the Global Navigation menu displayed

  @Guest @Automated @PDP_page @nikemobile
  Scenario: As a guest user, I should be able to navigate to a PDP page by searching a product
    Given I am on mobile home page
    When I search for "shirts"
    Then I should see the search results page
    When I store the particular product name and I tap on it in mobile
    Then I should navigate to corresponding PDP page with that product name in mobile
