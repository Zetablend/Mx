class Api::V1::Merchant::ProfileController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_user

  def header
    render json: {
      success: true,
      data: {
        merchantName: @user.name,
        merchantType: @user.role,
        profileImage: @user.profile_image.attached? ? url_for(@user.profile_image) : nil,
        bannerImage: @user.banner_image.attached? ? url_for(@user.banner_image) : nil
      }
    }
  end

  def profile_image
    if params[:profileImage].present?
      @user.profile_image.purge if @user.profile_image.attached?
      @user.profile_image.attach(params[:profileImage])

      render json: {
        success: true,
        message: "Profile image updated successfully",
        data: {
          profileImage: @user.profile_image.attached? ? url_for(@user.profile_image) : nil
        }
      }
    else
      render json: {
        success: false,
        message: "Please select an image."
      }, status: :unprocessable_entity
    end
  end

  def banner
    if params[:bannerImage].present?
      @user.banner_image.purge if @user.banner_image.attached?
      @user.banner_image.attach(params[:bannerImage])

      render json: {
        success: true,
        message: "Banner updated successfully",
        data: {
          bannerImage: @user.banner_image.attached? ? url_for(@user.banner_image) : nil
        }
      }
    else
      render json: {
        success: false,
        message: "Please select an image."
      }, status: :unprocessable_entity
    end
  end

  def gallery
    render json: {
      success: true,
      data: @user.gallery_images.map.with_index(1) do |image, index|
        {
          image_id: "IMG#{1000 + index}",
          imageUrl: url_for(image)
        }
      end
    }
  end

  def upload_gallery
    return render json: {
      success: false,
      message: "Please select images."
    }, status: :unprocessable_entity unless params[:images].present?

    images = Array.wrap(params[:images])

    images.each do |image|
      @user.gallery_images.attach(image)
    end

    uploaded_images = @user.gallery_images.last(images.count)

    render json: {
      success: true,
      message: "Images uploaded successfully",
      data: uploaded_images.each_with_index.map do |image, index|
        {
          image_id: "IMG#{1000 + @user.gallery_images.count - uploaded_images.count + index + 1}",
          imageUrl: url_for(image)
        }
      end
    }
  end

  def social_links
    render json: {
      success: true,
      data: {
        instagram: @user.instagram,
        facebook: @user.facebook,
        linkedIn: @user.linkedin,
        youtube: @user.youtube
      }
    }
  end

  def update_social_links
    if @user.update(social_links_params)
      render json: {
        success: true,
        message: "Social links updated successfully"
      }
    else
      render json: {
        success: false,
        message: @user.errors.full_messages.first
      }, status: :unprocessable_entity
    end
  end

  def information
    render json: {
      success: true,
      data: {
        businessName: @user.name,
        email: @user.email,
        phoneNumber: @user.phone,
        businessCategory: @user.business_category,
        address: @user.address,
        website: @user.website,
        aboutBusiness: @user.about_business
      }
    }
  end

  def update_information
    if @user.update(profile_params)
      render json: {
        success: true,
        message: "Profile information updated successfully",
        data: {
          businessName: @user.name
        }
      }
    else
      render json: {
        success: false,
        message: @user.errors.full_messages.first
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    user_id = params[:user_id] || params.dig(:profile, :user_id)

    @user = User.find_by(id: user_id)

    unless @user
      render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end
  end

  def profile_params
    params.permit(
      :name,
      :email,
      :phone,
      :business_category,
      :address,
      :website,
      :about_business
    )
  end

  def social_links_params
    params.permit(
      :instagram,
      :facebook,
      :linkedin,
      :youtube
    )
  end
end
