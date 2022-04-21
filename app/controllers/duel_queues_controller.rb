class DuelQueuesController < InheritedResources::Base
  before_action :authenticate_user!

  def index
    @duel_queues = current_user.duel_queues
  end

  def new
    @duel_queue = DuelQueue.new
    @duel_queue.ai1 = "MCTS"
    @duel_queue.ai2 = "MCTS"
    @duel_queue.ai1_strength = 6
    @duel_queue.ai2_strength = 6
    default = DuelQueue.default
    @duel_queue.magarena_version_major = default.magarena_version_major
    @duel_queue.magarena_version_minor = default.magarena_version_minor
    @duel_queue.life = 20
  end

  def create
    @duel_queue = DuelQueue.new(duel_queue_params)
    @duel_queue.user = current_user
    @duel_queue.access_token = DuelQueue.generate_token
    @duel_queue.active = true

    respond_to do |format|
      if @duel_queue.save
        format.html { redirect_to @duel_queue, notice: 'Duel Queue was successfully created.' }
        format.json { render action: 'show', status: :created, location: @duel_queue }
      else
        format.html { render action: 'new' }
        format.json { render json: @duel_queue.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @duel_queue = current_user.duel_queues.find(params[:id])
  end

  def update
    @duel_queue = current_user.duel_queues.find(params[:id])
    super
  end

  def destroy
    @duel_queue = current_user.duel_queues.find(params[:id])
    super
  end
  private

    def duel_queue_params
      params.require(:duel_queue).permit(:name, :magarena_version_minor, :magarena_version_major, :ai1, :ai2, :ai1_strength, :ai2_strength, :custom_params, :life)
    end
end

