##Meteor.startup ->
  ##if Meteor.coins.find().count() is 0
if Coins.find().count() is 0
  Coins.insert
    name: 'Bitcoin'
    avg_value: 1000
  Coins.insert
    name: 'Litecoin'
    avg_value: 40
  Coins.insert
    name: 'NameCoin'
    avg_value: 8
  Coins.insert
    name: 'FeatherCoin'
    avg_value: 5
