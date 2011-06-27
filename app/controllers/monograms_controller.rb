class MonogramsController < ApplicationController
  # GET /monograms
  # GET /monograms.xml
  def index
    @monograms = Monogram.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @monograms }
    end
  end

  # GET /monograms/1
  # GET /monograms/1.xml
  def show
    @monogram = Monogram.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @monogram }
    end
  end

  # GET /monograms/new
  # GET /monograms/new.xml
  def new
    @monogram = Monogram.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @monogram }
    end
  end

  # GET /monograms/1/edit
  def edit
    @monogram = Monogram.find(params[:id])
  end

  # POST /monograms
  # POST /monograms.xml
  def create
    @monogram = Monogram.new(params[:monogram])

    respond_to do |format|
      if @monogram.save
        format.html { redirect_to(@monogram, :notice => 'Monogram was successfully created.') }
        format.xml  { render :xml => @monogram, :status => :created, :location => @monogram }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @monogram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /monograms/1
  # PUT /monograms/1.xml
  def update
    @monogram = Monogram.find(params[:id])

    respond_to do |format|
      if @monogram.update_attributes(params[:monogram])
        format.html { redirect_to(@monogram, :notice => 'Monogram was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @monogram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /monograms/1
  # DELETE /monograms/1.xml
  def destroy
    @monogram = Monogram.find(params[:id])
    @monogram.destroy

    respond_to do |format|
      format.html { redirect_to(monograms_url) }
      format.xml  { head :ok }
    end
  end
end
