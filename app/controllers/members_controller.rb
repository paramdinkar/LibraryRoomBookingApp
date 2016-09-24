class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  # GET /members
  # GET /members.json
  def index
    @members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  def managereservation
    #@room = Room.where("status LIKE ?", "Reserved")
    @member = Member.where("email LIKE ?", session[:email]).first
    @reservations = @member.reservations
    render 'reservations/managereservation'
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  def signin
  end

  def welcome
    params.permit('password', 'email')
    if params['email'].empty? or params['password'].empty?
      flash[:notice] = "UserName/Password cannot be empty"
      render 'members/signin'
    end
    @member = Member.where("email LIKE ? and password LIKE ?", params['email'], params['password'])
    if @member.count == 0
      flash[:notice] = "UserName/Password not found. Please try again"
      render 'members/signin'
    end

    session[:email] = params['email']
    session[:name] = @member.collect {|member| member.name}
    puts @member.collect {|member| member.name}
  end
  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def addPermission
    render :updatepermission
  end

  def updatePermissionForMultipleReservations
    print session[:email]
    print '*******************'
    @member = Member.where("email LIKE ?", params['email'])
    if session[:email].nil? or session[:email].empty?
      flash[:notice] = "Please login before adding permission"
      render admins_signin_path and return
    end
    if @member.nil?
      flash[:notice] = "#{params['email']} - member not found. Please check email and try again"
      render :updatepermission and return
    end
    @member = @member.first
    member_permission = {:isMultipleReservationAllowed => 'Yes'}


    if @member.update(member_permission)
      flash[:notice] = "Permission added successfully"
      render :updatePermissionForMultipleReservations
    else
      flash[:notice] = "Update permission failed. Please try again"
      render :updatePermissionForMultipleReservations
    end

  end

  def pastReservations
    @member = Member.where("email LIKE ?", session[:email]).first
    @reservations = @member.reservations.where("end_time <= ?", Time.now)
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:name, :password, :email)
    end
end
