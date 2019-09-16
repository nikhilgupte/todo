# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Tag.find_or_create_by(title: 'Today')
wash_laundary = Task.find_or_create_by(title: 'Wash laundry')
wash_laundary.tag_names = ['Today']
