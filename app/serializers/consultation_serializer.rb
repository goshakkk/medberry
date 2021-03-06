class ConsultationSerializer < ApplicationSerializer
  attributes :id, :cause_category_id, :status, :mode,
    :diagnosis_category_id, :advice, :tokbox_session, :tokbox_token,
    :created_at, :expires_at, :finished_at, :finished_by, :duration,
    :extension

  has_one :doctor
  has_one :patient
  has_many :messages

  def tokbox_token
    object.tokbox_token_for_role(current_user.role)
  end

  def include_tokbox_token?
    current_user
  end

  def extension
    false
  end
end
