class S3sController < ApplicationController
  before_action :set_s3, only: [:show, :edit, :update, :destroy]

  # GET /s3s
  # GET /s3s.json
  def index
    @s3s = S3.order('created_at')
  end


  def perform
    s3 = S3.new
    webs = Web.all[0..1]
    s3.generate_s3_csv(webs)
    render :index
  end


  def download_csv
    s3 = S3.find(params[:id])
    path = s3.csv.expiring_url
    redirect_to path

    # data = open(s3.csv.expiring_url)
    # send_data data.read, :type => data.content_type, :x_sendfile => true
    # send_data data.read, filename: "#{s3.csv_file_name}", type: "text/csv", disposition: 'attachment'

    # render :index
  end


  # def download_csv
  #   s3 = Photo.find(params[:id])
  #   style_name=:original
  #   file_name = s3.csv_file_name
  #
  #   s3.s3_bucket.objects[s3.s3_object(style_name).key].url_for(:read,
  #     :secure => true,
  #     :expires => 24*3600,  # 24 hours
  #     :response_content_disposition => "attachment; filename='#{csv_file_name}'").to_s
  #
  #   render :index
  # end



  # GET /s3s/1
  # GET /s3s/1.json
  def show
  end

  # DELETE /s3s/1
  # DELETE /s3s/1.json
  def destroy
    @s3.destroy
    respond_to do |format|
      format.html { redirect_to s3s_url, notice: 'S3 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_s3
      @s3 = S3.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def s3_params
      params.fetch(:s3, {})
    end
end
