# frozen_string_literal: true

def login(user)
  visit ''
  click_link 'Login'
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Submit'
  sleep(0.1)
end

# Use a material design select.
# Use the text of the option as `name` and the form control as `from`.
# This is ugly, but it was the only option that I was able to get to work.
def mat_select(name, from: nil, id: nil)
  raise ArgumentError if from && id
  raise ArgumentError unless from || id

  find("mat-select[formControlName='#{from}']").click if from
  find("##{id}").click if id
  find('mat-option', text: name).click
end

def extract_first_link_path(email)
  email.body.match(%r{(?:"https?://.*?)(/.*?)(?:")}).captures[0]
end
