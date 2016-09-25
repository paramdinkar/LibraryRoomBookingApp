class AdminsController < ApplicationController

  before_action :set_admin, only: [:show, :edit, :update, :destroy]

  # GET /admins
  # GET /admins.json
  def index
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end

    @admins = Admin.all
  end

  def managemember
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end

    @members = Member.all
    render 'admins/managemember'
  end

  def managereservation
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end

    @reservations = Reservation.all
    render 'reservations/manageadminreservation'
  end
  # GET /admins/1
  # GET /admins/1.json
  def show

  end

  # GET /admins/new
  def new
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end
    @admin = Admin.new
  end

  def signin
  end

  def welcome
    params.permit('password', 'email')
    if params['email'].empty? or params['password'].empty?
      flash[:notice] = "UserName/Password cannot be empty"
      render 'admins/signin'
    end

    @admin = Admin.where("email LIKE ? and password LIKE ?", params['email'], params['password'])
    if @admin.count == 0
      flash[:notice] = "UserName/Password not found. Please try again"
      render 'admins/signin'
    end

    session[:email] = params['email']
    session[:name] = @admin.collect {|member| member.name}
    session[:role] = "admin"
  end

  # GET /admins/1/edit
  def edit
  end

  def isAdminLoggedIn
    if not session[:email].nil? and not session[:email].empty?
      if not session[:role].nil? and session[:role] == 'admin'
        return true
      else
        return false
      end
    end

    return false
  end

  # POST /admins
  # POST /admins.json
  def create

    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.html { redirect_to @admin, notice: 'Admin was successfully created.' }
        format.json { render :show, status: :created, location: @admin }
      else
        format.html { render :new }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def homepage
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end
    @admin = Admin.where("email LIKE ?", session[:email])
    render admins_welcome_path
  end

  def getmembersWithMultipleReservation
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end
    @member = Member.where("isMultipleReservationAllowed LIKE ?", 'Yes')
    render :showMembersWithMultipleReservePermission
  end


  # PATCH/PUT /admins/1
  # PATCH/PUT /admins/1.json
  def update
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end

    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to @admin, notice: 'Admin was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin }
      else
        format.html { render :edit }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    status_code = isAdminLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render admins_signin_path and return
    end
    @admin.destroy
    respond_to do |format|
      format.html { redirect_to admins_url, notice: 'Admin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params.require(:admin).permit(:name, :password, :email)
    end
end
