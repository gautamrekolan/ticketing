class RawUnimportedEmailsController < ApplicationController

  def index
    @raw_unimported_emails = RawUnimportedEmail.all
  end

  def show
    @raw_unimported_email = RawUnimportedEmail.find(params[:id])
  end

end
