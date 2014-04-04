class ConsultationRequestSerializer < ApplicationSerializer
  attributes :id, :cause, :status, :created_at

  has_one :doctor
  has_one :patient
  has_one :consultation
  has_one :queue_meta, root: :consultation_request_queue_meta

  def queue_meta
    ConsultationRequestQueueMetaSerializer.new(ConsultationRequestQueueMeta.new(id: object.id))
  end
end
