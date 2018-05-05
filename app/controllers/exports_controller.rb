class ExportsController < ApplicationController
  before_action :set_export, only: [:show, :destroy]


  def index
    @exports = Export.order(export_date: :desc)
  end

  def download_csv
    export = Export.find(params[:id])
    path = export.csv.expiring_url
    flash[:notice] = "Exporting/Downloading Requested CSV"
    redirect_to path
  end


  def destroy
    @export.destroy
    respond_to do |format|
      format.html { redirect_to exports_url, notice: 'Export was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_export
      @export = Export.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def export_params
      params.fetch(:export, {})
    end
end
