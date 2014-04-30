Fabricator (:invite) do
  inviter { Fabricate(:user) }
  name { Faker::Name.name }
  email { Faker::Internet.email }
  message { Faker::Lorem.paragraph }
end
