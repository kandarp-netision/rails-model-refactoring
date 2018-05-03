class UpdateUser

    def initialize(params)
        @params = params
    end

    def save
        @user = User.find
        update_deactivate_user
        update_slug
        if @user.update user_params
            reset_featured_artists
            true
        else
            false
        end
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
