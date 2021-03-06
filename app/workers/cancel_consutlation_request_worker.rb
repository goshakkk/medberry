# Cancels the consultation requests when:
#
# 1. the doctor has been offline for more than 5 minutes
# 2. the patient has been offline for more than 5 minutes AND the request is
#    the first in the queue to that doctor
class CancelConsultationRequestWorker
  include BatchProcessor
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false
  recurrence { secondly(30) }

  attr_reader :status_service

  def initialize(status_service: Services.online_status)
    @status_service = status_service
  end

  def selector
    ConsultationRequest.in_status(:new)
  end

  def process(request)
    cause = cancelation_cause(request)
    return unless cause

    ConsultationRequestStatusChanger.new(request).cancel(cause)
  end

  def cancelation_cause(request)
    return false unless request.new_request?

    doctor = request.doctor
    patient = request.patient

    queue = QueueService.new(doctor)

    return :doctor_offline if not_recently_online?(doctor)
    return :patient_offline if not_recently_online?(patient) && queue.next_request == request
  end

  def not_recently_online?(identity)
    !status_service.was_recently_online?(identity.user, window: 5.minutes)
  end
end
