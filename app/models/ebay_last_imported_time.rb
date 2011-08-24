class EbayLastImportedTime < ActiveRecord::Base
	include ActiveRecord::Singleton
end
# == Schema Information
#
# Table name: ebay_last_imported_times
#
#  id          :integer         not null, primary key
#  last_import :datetime
#

