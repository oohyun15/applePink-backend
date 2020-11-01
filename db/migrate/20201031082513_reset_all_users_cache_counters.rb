class ResetAllUsersCacheCounters < ActiveRecord::Migration[6.0]
  def up
    User.all.each do |user|
      Post.reset_counters(user.id, :reports)
    end

    User.all.each do |user|
      Post.reset_counters(user.id, :likes)
    end
  end

  def down 
    # no rollback needed
  end
end
