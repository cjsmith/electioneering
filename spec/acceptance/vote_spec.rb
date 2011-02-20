require File.dirname(__FILE__) + '/acceptance_helper'

feature "Voting", %q{
  In order to be able to quickly register my vote on some choices
  As a voter
  I want to vote 3 times and see the results
} do

  scenario "Voting for the first time, I should see a list of the candidates" do
    visit('/')
    page.should have_content "Pick One."
	  page.should have_content "Obama"
	  page.should have_content "Palin"
  end

  scenario "I should be prompted to vote 3 times and then shown the results" do 
    visit('/')
	  click_button('Obama')
    click_button('Palin')
    click_button('Obama')
    page.should have_content "Results:"
    find('tr#Obama').should have_content('2 votes') 
    find('tr#Palin').should have_content('1 vote') 
  end

  scenario "I should not be able to vote more than 3 times" do 
    visit('/')
	  click_button('Obama')
    click_button('Palin')
    click_button('Obama')
    page.should have_content "Results:"
    visit('/')
    page.should have_content "Results:"
  end
end
