class InvoicesController < ApplicationController

  def index
    @orders = Order.all
  end

end
