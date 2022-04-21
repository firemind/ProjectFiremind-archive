class CreateDuelQueues < ActiveRecord::Migration[5.0]
  def change
    create_table :duel_queues do |t|
      t.string :name, null: false
      t.string :access_token
      t.string :ai1, null: false
      t.string :ai2, null: false
      t.integer :ai1_strength, null: false
      t.integer :ai2_strength, null: false
      t.integer :magarena_version_major, null: false
      t.integer :magarena_version_minor, null: false
      t.integer :life, null: false
      t.integer :user_id
      t.boolean :active
      t.text :custom_params

      t.timestamps
    end
    add_index(:duel_queues, [:name], :unique => true)
    add_index(:duel_queues, [:access_token], :unique => true)
    add_column :duels, :duel_queue_id, :integer
    add_column :ai_rating_matches, :duel_queue_id, :integer

    Duel.select("distinct(worker_queue)").where("worker_queue like 'airm%'").each do |d|
      d = Duel.where(worker_queue: d.worker_queue).first
      queue_name = d.worker_queue
      dq = DuelQueue.new
      dq.name = queue_name
      airm = nil
      if dq.name[0..3] == "airm" && airm = AiRatingMatch.where(id: dq.name[4..-1].to_i).first
        dq.ai1 = airm.ai1_name
        dq.ai2 = airm.ai2_name
        dq.ai1_strength   = airm.ai_strength
        dq.ai2_strength   = airm.ai_strength
        dq.access_token   = DuelQueue.generate_token
      else
        dq.ai1 = 'MCTS'
        dq.ai2 = 'MCTS'
        dq.ai1_strength   = 6
        dq.ai2_strength   = 6
        dq.access_token   = DuelQueue.generate_token
      end
      dq.magarena_version_minor = d.magarena_version_minor || 1
      dq.magarena_version_major = d.magarena_version_major || 0
      dq.active = false
      dq.life = 20
      puts dq.name
      puts dq.access_token
      dq.save!
      Duel.where(worker_queue: d.worker_queue).update_all(duel_queue_id: dq.id)
      if airm
        airm.duel_queue = dq
        airm.save(validate: false)
      end
    end
    change_column :ai_rating_matches, :duel_queue_id, :integer, null: false
    Duel.select("distinct(magarena_version_minor)").where(worker_queue: [nil, 'new']).each do |d|
      minor = d.magarena_version_minor || 0
      version = "1.#{minor}"
      name = CURRENT_MAGARENA_VERSION == version ? "default" : "default-#{version}"
      dq = DuelQueue.where(name: name).first_or_initialize
      dq.magarena_version_minor = minor 
      dq.magarena_version_major = 1
      dq.ai1 = 'MCTS'
      dq.ai2 = 'MCTS'
      dq.ai1_strength   = 6
      dq.ai2_strength   = 6
      dq.life = 20
      dq.active = CURRENT_MAGARENA_VERSION == version
      puts dq.inspect
      dq.save!
      Duel.where(worker_queue: [nil, 'new'], magarena_version_minor: d.magarena_version_minor).update_all(duel_queue_id: dq.id)
    end

    Duel.where(worker_queue: 'sysnew').each do |d|
      minor = d.magarena_version_minor || 0
      version = "1.#{minor}"
      name = CURRENT_MAGARENA_VERSION == version ? "csm-test" : "csm-test-#{version}"
      dq = DuelQueue.where(name: name).first_or_initialize
      dq.magarena_version_minor = minor 
      dq.magarena_version_major = 1
      dq.ai1 = 'MCTS'
      dq.ai2 = 'MCTS'
      dq.ai1_strength   = 1
      dq.ai2_strength   = 1
      dq.life = 20
      dq.active = CURRENT_MAGARENA_VERSION == version
      dq.access_token = DuelQueue.generate_token
      dq.user = User.sysuser
      puts dq.inspect
      dq.save!
      Duel.where(worker_queue: :sysnew, magarena_version_minor: d.magarena_version_minor).update_all(duel_queue_id: dq.id)
    end


    change_column :duels, :duel_queue_id, :integer, null: false
    remove_column :duels, :worker_queue
    remove_column :duels, :ai1
    remove_column :duels, :ai2
    remove_column :duels, :str_ai1
    remove_column :duels, :str_ai2

  end
end
