class ResetAllModelsCacheCounters < ActiveRecord::Migration[6.0]
  def up
    Post.all.each do |post|
      Post.reset_counters(post.id, :reports)
    end

    Post.all.each do |post|
      Post.reset_counters(post.id, :likes)
    end

    Location.all.each do |location|
      Location.reset_counters(location.id, :likes)
    end
  end

  def down 
    # no rollback needed
  end
end
