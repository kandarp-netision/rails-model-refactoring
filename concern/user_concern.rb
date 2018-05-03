module UserConcern
  extend ActiveSupport::Concern

  def update_deactivate_user
    if changed.include?('is_active')
      if is_active?
        show_user_data
      else
        hide_user_data
        UserMailer.notify_user_deactivation(self).deliver_later unless new_record?
      end
    end
  end

  def update_slug
    self.slug = username if changed.include?('username')
  end

  def create_notification_setting
    NotificationSetting.create(user_id: id)
  end

  def update_points
    update(total_points: USER_CREATION_POINTS)
    PointsHistory.create_points_history(total_points, POINT_ACTIONS[:user_create], id, USER_CREATION_POINTS, self.class.name)
  end

  def strip_whitespace
    self.username = username.strip if username
    self.screen_name = screen_name.strip if screen_name
    self.email = email.strip if email
  end

  def reset_featured_artists
    Rails.cache.delete('featured_artists') if changed.include?('featured')
  end

  def hide_user_data
    activate_in_active_user_data(false)
    device_tokens.destroy_all
    tokens.destroy_all
  end

  def show_user_data
    activate_in_active_user_data
  end

  def activate_in_active_user_data(active = true)
    Audio.unscoped.where(user_id: id).update_all(active: active)
  end
end
