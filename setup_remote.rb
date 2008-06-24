#!/usr/bin/env ruby
map = {
  "Phrogz" => "harold",
  "harold" => "Phrogz"
}
user = IO.read( ".git/config" )[ /remote "origin".+?(Phrogz|harold)/m , 1]

other_user = map[user]
`git remote add #{other_user} git://github.com/#{other_user}/mab.git`
`git fetch #{other_user}`