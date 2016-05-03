Feature: Verify if a user is able to view the page contents properly

  @Guest @Automated @image_text @desktop_nike
  Scenario: Verify the navigation of images on clicking arrow button in home page
    Given I am on browser home page
    When I tap on the nike logo
    Then I should see the content displayed in image in home page

  @Guest @Automated @image_text @desktop_nike
  Scenario Outline: Verify the image content on clicking categories in home page
    Given I am on browser home page
    When I tap "<category>" in the header
    Then I should see the URL and header corresponding to "<category>"
    And I should see the <text> text of image in the page
  Examples:
    | category | text               |
    | WOMEN    | JOIN THE FREE      |
    | BOYS     | UNLEASH YOUR BEAST |
    | GIRLS    | UNLEASH YOUR       |

  @Guest @Automated @pop_up @desktop_nike
  Scenario: Guest user should be able to view the sub-navigation container
    Given I am on browser home page
    When I focus on the men link
    Then I should see the corresponding subnavigation container

  @Guest @Automated @PDP_Page @desktop_nike
  Scenario: As a guest user, a user should be able to navigate to product display page
    Given I am on browser home page
    When I tap "BOYS" in the header
    Then I should see the URL and header corresponding to "BOYS"
    When I tap on the shop now link
    Then I see category browse page with filter option
    When I store the particular product name and I tap on it
    Then I should navigate to corresponding PDP page with that product name
