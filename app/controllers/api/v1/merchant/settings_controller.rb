module Api
  module V1
    module Merchant
      class SettingsController < ApplicationController
        skip_before_action :authenticate_request

        # GET /api/v1/merchant/settings/business-information
        def business_information
          user = find_merchant
          return unless user

          business_info = MerchantBusinessInformation.find_by(
            user_id: user.id
          )

          render json: {
            success: true,
            data: {
              businessName: business_info&.business_name,
              brandEmail: business_info&.brand_email,
              gstVatNumber: business_info&.gst_vat_number,
              panTaxNumber: business_info&.pan_tax_number,
              bankAccount: business_info&.bank_account,
              phoneNumber: business_info&.phone_number
            }
          }
        end

        # PUT /api/v1/merchant/settings/business-information
        def update_business_information
          user = find_merchant
          return unless user

          business_info = MerchantBusinessInformation.find_or_initialize_by(
            user_id: user.id
          )

          if business_info.update(business_information_params)
            render json: {
              success: true,
              message: "Business information updated successfully"
            }
          else
            render json: {
              success: false,
              errors: business_info.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def find_merchant
          user =  ::User.find_by(
            id: params[:user_id] || params[:merchant_id]
          )

          unless user
            render json: {
              success: false,
              message: "Merchant not found"
            }, status: :not_found

            return nil
          end

          unless user.role == "merchant"
            render json: {
              success: false,
              message: "User is not a merchant"
            }, status: :unprocessable_entity

            return nil
          end

          user
        end

        def business_information_params
          {
            business_name: params[:businessName],
            brand_email: params[:brandEmail],
            gst_vat_number: params[:gstVatNumber],
            pan_tax_number: params[:panTaxNumber],
            bank_account: params[:bankAccount],
            phone_number: params[:phoneNumber]
          }
        end
      end
    end
  end
end
