# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110916191951) do

  create_table "attachments", :force => true do |t|
    t.integer "message_id"
    t.string  "filename"
	t.binary "content"
    t.string  "content_type"
  end

  create_table "conversations", :force => true do |t|
    t.integer "customer_id"
    t.boolean "status"
  end

  create_table "customer_emails", :force => true do |t|
    t.string   "address"
    t.integer  "customer_id"
  end
  create_table "ebay_last_imported_times", :force => true do |t|
    t.datetime "last_import"
  end
 
  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string     "eias_token"
    t.string    "ebay_user_id"
  end
  
  create_table "customer_addresses", :force => true do |t|
    t.belongs_to :customer
    t.string :name
    t.string :company
    t.string :address_1
    t.string :address_2
    t.string :town
    t.string :county
    t.string :country
    t.string :postcode
    t.string :ebay_address_id
  end

  create_table "guests", :force => true do |t|
    t.string   "name_on_envelope"
    t.string   "name_on_invitation"
    t.string   "address"
    t.string   "postcode"
  end

  create_table "guests_items", :id => false, :force => true do |t|
    t.integer "guest_id"
    t.integer "item_id"
  end
  
  create_table "customer_emails_outgoing_messages", :id => false, :force => true do |t|
    t.integer "outgoing_message_id"
    t.integer "customer_email_id"
  end
  
  create_table "messages_reply_to_addresses", :id => false, :force => true do |t|
    t.integer "message_id"
    t.integer "customer_email_id"
  end

  create_table "messages_from_addresses", :id => false, :force => true do |t|
    t.integer "message_id"
    t.integer "customer_email_id"
  end
  
  create_table "items", :force => true do |t|
    t.integer  "product_id"
    t.integer  "price"
    t.integer  "quantity_ordered"
    t.integer  "quantity_despatched"
    t.integer  "order_id"
    t.string "ebay_order_line_item_token"
  end

  create_table "ebay_messages", :force => true do |t|
    t.string :item_number
    t.integer :ebay_message_identifier
    t.belongs_to :customer_email
    t.string :subject
    t.text :content
    t.datetime :datetime
    t.belongs_to :conversation
  end

  create_table "messages", :force => true do |t|
    t.text    "content"
    t.string "subject"
    t.integer "conversation_id"
    t.datetime    "datetime"
  end

  create_table "monograms", :force => true do |t|
    t.string   "description"
  end

	create_table "raw_emails", :force => true do |t|
    t.text "content"
    t.belongs_to "message"
  end

  create_table "raw_unimported_emails", :force => true do |t|
    t.text "content"
    t.string "error"
    t.timestamps
  end

  create_table "orders", :force => true do |t|
    t.integer  "monogram"
    t.integer  "customer_id"
    t.integer "customer_address_id"
    t.string "ebay_order_identifier"
    t.string   "status"
    t.text     "notes"
    t.timestamps
  end
  
  create_table "template_emails", :force => true do |t|
    t.text "content"
    t.string "subject"
  end
  
  create_table "papers", :force => true do |t|
    t.integer "weight"
    t.string "texture"
    t.string "colour"
  end
  create_table "outgoing_messages", :force => true do |t|
    t.string "subject"
    t.text "content"
    t.belongs_to :message
    t.timestamps
  end
  create_table "product_formats", :force => true do |t|
    t.string   "description"
    t.integer  "height"
    t.integer  "width"
    t.string   "style"
  end

  create_table "product_types", :force => true do |t|
    t.string   "description"
    t.boolean  "envelope"
  end

  create_table "products", :force => true do |t|
    t.integer "product_type_id"
    t.integer "product_format_id"
    t.integer "theme_id"
    t.integer "paper_id"
    t.integer "price"
    t.integer "character_limit"
  end

  create_table "themes", :force => true do |t|
    t.string   "name"
  end
  
  create_table "mail_merge_guests", :force => true do |t|
    t.belongs_to "customer"
    t.text "address"
    t.boolean "hand" 
  end

end
