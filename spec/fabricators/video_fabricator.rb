Fabricator(:video) do
  title { Faker::Lorem.words(3).join(' ').capitalize }
  description { Faker::Lorem.sentences(2).join(' ') }
  categories { [Fabricate(:category)] }
end