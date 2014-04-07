Fabricator(:relationship) do
  user { Fabricate(:user) }
  followed_user { Fabricate(:user) }
end