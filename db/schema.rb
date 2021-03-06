# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140421155802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "admins", force: true do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree

  create_table "consultation_requests", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "patient_id"
    t.uuid     "doctor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",            default: 0
    t.integer  "cancelation_cause"
    t.datetime "canceled_at"
    t.string   "cause_category_id"
  end

  add_index "consultation_requests", ["doctor_id"], name: "index_consultation_requests_on_doctor_id", using: :btree
  add_index "consultation_requests", ["patient_id"], name: "index_consultation_requests_on_patient_id", using: :btree

  create_table "consultation_sessions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "consultation_id"
    t.text     "tokbox_token_patient"
    t.text     "tokbox_token_doctor"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "consultation_sessions", ["consultation_id"], name: "index_consultation_sessions_on_consultation_id", using: :btree

  create_table "consultation_transitions", force: true do |t|
    t.string   "to_state"
    t.hstore   "metadata"
    t.integer  "sort_key"
    t.uuid     "consultation_id"
    t.datetime "created_at"
  end

  add_index "consultation_transitions", ["consultation_id"], name: "index_consultation_transitions_on_consultation_id", using: :btree
  add_index "consultation_transitions", ["sort_key", "consultation_id"], name: "index_consultation_transitions_on_sort_key_and_consultation_id", unique: true, using: :btree

  create_table "consultations", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "patient_id"
    t.uuid     "doctor_id"
    t.uuid     "request_id"
    t.string   "tokbox_session"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                default: 0
    t.datetime "finished_at"
    t.integer  "finished_by"
    t.integer  "finishing_cause"
    t.integer  "mode",                  default: 2
    t.integer  "duration"
    t.string   "diagnosis_category_id"
    t.text     "advice"
    t.string   "cause_category_id"
  end

  add_index "consultations", ["doctor_id"], name: "index_consultations_on_doctor_id", using: :btree
  add_index "consultations", ["patient_id"], name: "index_consultations_on_patient_id", using: :btree
  add_index "consultations", ["request_id"], name: "index_consultations_on_request_id", using: :btree

  create_table "doctor_patient_connections", force: true do |t|
    t.uuid     "doctor_id"
    t.uuid     "patient_id"
    t.datetime "created_at"
  end

  create_table "doctors", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.integer "practice",   default: 0
  end

  create_table "favorite_doctors", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "patient_id"
    t.uuid     "doctor_id"
    t.datetime "created_at"
  end

  add_index "favorite_doctors", ["doctor_id"], name: "index_favorite_doctors_on_doctor_id", using: :btree
  add_index "favorite_doctors", ["patient_id"], name: "index_favorite_doctors_on_patient_id", using: :btree

  create_table "insurance_companies", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "name"
  end

  create_table "insurance_policies", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid   "insurance_company_id"
    t.string "number"
  end

  add_index "insurance_policies", ["insurance_company_id"], name: "index_insurance_policies_on_insurance_company_id", using: :btree

  create_table "messages", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "consultation_id"
    t.uuid     "sender_id"
    t.text     "text"
    t.datetime "created_at"
  end

  add_index "messages", ["consultation_id"], name: "index_messages_on_consultation_id", using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree

  create_table "patients", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "bsn"
    t.string "first_name"
    t.string "last_name"
    t.string "gender"
    t.date   "dob"
    t.string "zip"
    t.string "address"
    t.string "city"
    t.uuid   "insurance_policy_id"
  end

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "identity_id"
    t.string   "identity_type"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.uuid     "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
