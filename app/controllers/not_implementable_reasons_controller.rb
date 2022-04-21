class NotImplementableReasonsController < InheritedResources::Base
  before_action :authenticate_user!
  def index
    raise "bad" unless current_user.may_add_unimplementable_reasons
    @not_implementable_reasons = NotImplementableReason.all
  end

  def create
    @not_implementable_reason = NotImplementableReason.new(not_implementable_reason_params)
    @not_implementable_reason.user = current_user
    create!
  end

  private

  def not_implementable_reason_params
    params.require(:not_implementable_reason).permit(:name, :description)
  end
end

