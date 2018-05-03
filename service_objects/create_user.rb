class CreateUser

    def initialize(params)
        @params = params
    end

    def save
        @user = User.new user_params
        update_deactivate_use
        update_slug
        if @user.save
            create_notification_setting
            update_points
            strip_whitespace
            reset_featured_artists
            true
        else
            false
        end
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

end
