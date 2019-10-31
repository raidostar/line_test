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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_28_083219) do

  create_table "books", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "publisher"
    t.string "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "release_at"
  end

  create_table "emojis", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "moji_text"
    t.string "img_url"
    t.binary "unicode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "group"
    t.integer "follower"
    t.integer "targetedReaches"
    t.integer "blocks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
  end

  create_table "friends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "fr_account"
    t.string "fr_name"
    t.string "profile_pic"
    t.string "profile_msg"
    t.boolean "block", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group_id"
    t.datetime "last_message_time"
    t.datetime "block_at"
    t.datetime "follow_at"
    t.string "tags"
    t.text "last_message"
    t.integer "disney_point", default: 0
    t.integer "final_question", default: 0
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "group"
    t.string "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group_key"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "sender"
    t.string "receiver"
    t.text "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_type"
    t.string "message_id"
    t.string "sticker_id"
    t.string "package_id"
    t.string "fr_account"
    t.string "group_id"
    t.string "reply_token"
    t.string "check_status"
    t.string "image"
  end

  create_table "notifies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "sender"
    t.string "receiver"
    t.text "contents"
    t.string "notify_type"
    t.string "fr_account"
    t.string "group_id"
    t.string "target_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hit_count"
    t.string "image"
  end

  create_table "options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "match_reaction"
    t.integer "action_count"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_group"
    t.string "target_day"
    t.string "target_time"
    t.string "target_keyword"
    t.string "target_friend"
    t.string "option_type"
    t.boolean "bool", default: false
    t.string "remind_after"
    t.integer "hit_count", default: 0
  end

  create_table "people", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "join_in"
    t.date "withdraw_at"
    t.boolean "block"
  end

  create_table "reactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.text "contents"
    t.string "reaction_type"
    t.string "user_group"
    t.string "tag"
    t.integer "target_number"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bool", default: false
    t.string "match_option"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "tag_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_group"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group", default: "0"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

end
