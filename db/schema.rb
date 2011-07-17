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

ActiveRecord::Schema.define(:version => 20110716180630) do

  create_table "attachments", :force => true do |t|
    t.integer "message_id"
    t.string  "filename"
    t.string  "content_type"
  end

  create_table "conversations", :force => true do |t|
    t.integer "customer_id"
  end

  create_table "customer_emails", :force => true do |t|
    t.string   "address"
    t.integer  "customer_id"
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string     "eias_token"
    t.string    "ebay_user_id"
  end
  
  create_table "customer_addresses", :force => true do |t|
    t.belongs_to :customer
    t.string :address_1
    t.string :address_2
    t.string :town
    t.string :county
    t.string :country
    t.string :postcode
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

  create_table "items", :force => true do |t|
    t.integer  "product_id"
    t.integer  "price"
    t.integer  "quantity_ordered"
    t.integer  "quantity_despatched"
    t.integer  "order_id"
    t.string "ebay_order_line_item_token"
  end

  create_table "messages", :force => true do |t|
    t.text    "content"
    t.integer "conversation_id"
    t.date    "datetime"
  end

  create_table "monograms", :force => true do |t|
    t.string   "description"
  end

  create_table "orders", :force => true do |t|
    t.integer  "monogram"
    t.integer  "customer_id"
    t.string "ebay_order_identifier"
    t.string   "status"
    t.text     "notes"
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
    t.integer "price"
  end

  create_table "themes", :force => true do |t|
    t.string   "name"
  end
  
  create_table "mail_merge_guests", :force => true do |t|
    t.belongs_to "customer"
    t.text "address", :limit => 1000
    t.boolean "hand" 
  end

end
