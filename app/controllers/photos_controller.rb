class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.order('created_at')
  end



  def perform
    photo = Photo.new
    webs = Web.all[0..1]
    photo.generate_s3_csv(webs)
    render :index
  end


  # def download_csv
  #   photo = Photo.find(params[:id])
  #   data = open(photo.csv.expiring_url)
  #   send_data data.read, :type => data.content_type, :x_sendfile => true
  #
  #   data = photo.csv.expiring_url
  #   redirect_to path
  #   send_data data.read, filename: "#{photo.csv_file_name}", type: "text/csv", disposition: 'attachment'
  # end

  def download_csv
    photo = Photo.find(params[:id])
    style_name=:original
    file_name = photo.csv_file_name

    photo.s3_bucket.objects[photo.s3_object(style_name).key].url_for(:read,
      :secure => true,
      :expires => 24*3600,  # 24 hours
      :response_content_disposition => "attachment; filename='#{csv_file_name}'").to_s

    render :index  
  end




  # GET /photos/1
  # GET /photos/1.json
  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(photo_params)
    if @photo.save
      flash[:success] = "The photo was added!"
      redirect_to root_path
    else
      render 'new'
    end

    # respond_to do |format|
    #   if @photo.save
    #     format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
    #     format.json { render :show, status: :created, location: @photo }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @photo.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:image, :title)
    end
end
