class UserPolicy
  def initialize(user)
    @user = user
  end

  def following?(other_user)
    @user.relationships.find_by(followed_id: @user.other_user.id).present?
  end

  def admin?
    @user.app_roles.pluck(:name).include?('admin') || @user.is_admin?
  end

  def following_or_follows?(recipient_id)
    follows_and_follower_ids = @user.following_and_followers_ids
    follows_and_follower_ids.include?(recipient_id)
  end

  def is_admin?
    ADMIN_EMAILS.include?(email)
  end
end
