class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    # Handle OAuth users differently - they don't need current password
    if resource.social_login?
      resource_updated = update_resource_without_password(resource, account_update_params)
    else
      resource_updated = update_resource(resource, account_update_params)
    end

    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # Configure permitted parameters for account update
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # For OAuth users, update without requiring current password
  def update_resource_without_password(resource, params)
    resource.update_without_password(params)
  end

  # The path used after sign up for inactive accounts
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  # The path used after updating the resource
  def after_update_path_for(resource)
    edit_user_registration_path
  end

  # Check if we should sign in the user after changing their password
  def sign_in_after_change_password?
    true
  end

  # Set flash message for successful update
  def set_flash_message_for_update(resource, prev_unconfirmed_email)
    if resource.social_login?
      flash_key = :notice
      flash_message = "Your profile was successfully updated."
    else
      flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :notice : :notice
      flash_message = find_message(flash_key, not: :confirmed)
    end

    set_flash_message(flash_key, flash_message) if is_flashing_format?
  end

  # Check if the update requires email confirmation
  def update_needs_confirmation?(resource, previous)
    resource.respond_to?(:pending_reconfirmation?) &&
      resource.pending_reconfirmation? &&
      previous != resource.unconfirmed_email
  end

  # Find the appropriate message
  def find_message(key, options = {})
    if key == :notice
      if options[:not] == :confirmed
        "Your account has been updated successfully, but we need to verify your new email address. Please check your email and follow the confirm link to confirm your new email address."
      else
        "Your account has been updated successfully."
      end
    else
      I18n.t("devise.registrations.updated")
    end
  end
end
