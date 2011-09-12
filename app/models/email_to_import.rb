class EmailToImport < ActiveRecord::Base
  establish_connection "email"
end
