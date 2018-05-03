class UserQuery
  def initialize(relation = User.scoped)
    @relation = relation
  end

  def search_user(user_name)
    @relation.where('users.username like ? OR users.screen_name like ?', "#{user_name}%", "#{user_name}%").order('users.username').select_user_fields
  end

  def all_users(logged_user)
    @relation.where.not(id: logged_user.id)
  end

  def except_users(user_ids)
    @relation.where('users.id NOT IN (?)', user_ids)
  end

  def for_user_unscoped
    @relation.unscope(where: [:is_active, :deleted, :suspended])
  end

  def popular
    @relation.order('total_points DESC')
  end

  def featured_artists
    @relation.where(featured: true)
  end

  def select_user_fields
    @relation.select('users.id, users.username, users.screen_name, users.image, users.updated_at, users.location, users.is_verified')
  end

  def user_worker_fields
    @relation.select(:id, :email, :username, :screen_name)
  end

  def search_priority(relationships)
    @relation.order(build_searching_order(relationships))
  end

  def tagging (current_user, keyword)
    @relation.all_users(current_user).where('username like ?', "#{keyword}%").order('username').select_user_fields.limit(TAGGING_RESULTS)
  end
end
