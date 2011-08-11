# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

EbayLastImportedTime.instance.update_attributes(:last_import => 6.days.ago.iso8601)
simplicity = Theme.create(:name => "Simplicity")
day_invitation = ProductType.create(:description => "Day Invitation")
a6_flat = ProductFormat.create(:width => 105, :height => 148, :description => "A6 flat", :style => "FLAT")
paper = Paper.new(:texture => "Smooth", :colour => "White", :weight => 80)
product = Product.new(:theme => simplicity, :product_format => a6_flat, :product_type => day_invitation, :paper => paper, :price => 10)
simplicity.products << product
