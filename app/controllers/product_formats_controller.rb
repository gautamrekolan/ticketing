class ProductFormatsController < ApplicationController
  # GET /product_formats
  # GET /product_formats.xml
  def index
    @product_formats = ProductFormat.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @product_formats }
    end
  end

  # GET /product_formats/1
  # GET /product_formats/1.xml
  def show
    @product_format = ProductFormat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product_format }
    end
  end

  # GET /product_formats/new
  # GET /product_formats/new.xml
  def new
    @product_format = ProductFormat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product_format }
    end
  end

  # GET /product_formats/1/edit
  def edit
    @product_format = ProductFormat.find(params[:id])
  end

  # POST /product_formats
  # POST /product_formats.xml
  def create
    @product_format = ProductFormat.new(params[:product_format])

    respond_to do |format|
      if @product_format.save
        format.html { redirect_to(@product_format, :notice => 'Product format was successfully created.') }
        format.xml  { render :xml => @product_format, :status => :created, :location => @product_format }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product_format.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /product_formats/1
  # PUT /product_formats/1.xml
  def update
    @product_format = ProductFormat.find(params[:id])

    respond_to do |format|
      if @product_format.update_attributes(params[:product_format])
        format.html { redirect_to(@product_format, :notice => 'Product format was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product_format.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /product_formats/1
  # DELETE /product_formats/1.xml
  def destroy
    @product_format = ProductFormat.find(params[:id])
    @product_format.destroy

    respond_to do |format|
      format.html { redirect_to(product_formats_url) }
      format.xml  { head :ok }
    end
  end
end
