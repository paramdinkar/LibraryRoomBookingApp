class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  # GET /members
  # GET /members.json
  def index
    status_code = isMemberLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end
    @members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show

  end

  def managereservation
    #@room = Room.where("status LIKE ?", "Reserved")
    status_code = isMemberLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end

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
    status_code = isMemberLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end
  end

  def signin
  end

  def welcome
    params.permit('password', 'email')
    if params['email'].empty? or params['password'].empty?
      flash[:notice] = "UserName/Password cannot be empty"
      render 'members/signin' and return
    end
    @member = Member.where("email LIKE ? and password LIKE ?", params['email'], params['password'])
    if @member.count == 0
      flash[:notice] = "UserName/Password not found. Please try again"
      render 'members/signin' and return
    end

    session[:email] = params['email']
    session[:role] = 'member'
    session[:name] = @member.collect {|member| member.name}
  end

  def homepage
    status_code = isMemberLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end
    @member = Member.where("email LIKE ?", session[:email])
    render members_welcome_path
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
    status_code = isMemberLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end
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
    status_code = isMemberLoggedIn(false)
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end

    render :updatepermission
  end

  def updatePermissionForMultipleReservations
    status_code = isMemberLoggedIn(false)
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end

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
    status_code = isMemberLoggedIn
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end
    #@member = Member.where("email LIKE ?", session[:email]).first
    emailmember = params[:email_param]
    @member = Member.where("email LIKE ?", emailmember).first
    @reservations = @member.reservations.where("end_time <= ?", Time.now)
  end

  def isMemberLoggedIn(verifyRole = true)
    if not session[:email].nil? and not session[:email].empty?
      if verifyRole
        if not session[:role].nil? and session[:role] == 'member'
          return true
        else
          return false
        end
      else
        return true
      end
    end

    return false
  end


  def searchRooms
    status_code = isMemberLoggedIn(false)
    if status_code == false
      render members_signin_path and return
    end

    currentTime = DateTime.now
    today = currentTime.beginning_of_day
    @weekDates = [[today.strftime("%m/%d/%Y"), today], [(today+1.day).strftime("%m/%d/%Y"), today+1.day], [(today+2.day).strftime("%m/%d/%Y"), today+2.day],
                  [(today+3.day).strftime("%m/%d/%Y"),today+3.day], [(today+4.day).strftime("%m/%d/%Y"),today+4.day], [(today+5.day).strftime("%m/%d/%Y"),today+5.day],
                  [(today+6.day).strftime("%m/%d/%Y"),today+6.day]]
    render :search
  end

  def getAvailabilityOfRoom(param_array, search_string)
    if not param_array[:date].nil? and not param_array[:date].empty?
      currentTime = DateTime.parse(param_array[:date])
      if currentTime < DateTime.now
        currentTime = DateTime.now
      end
    else
      currentTime = DateTime.now
    end

    rooms = nil

    if not param_array[:building].nil? and not param_array[:building].empty?
      rooms = Room.where(search_string[:building], param_array[:building])
      return nil if rooms.nil?
    end

    if not param_array[:size].nil? and not param_array[:size].empty?
      if rooms.nil?
         rooms = Room.where(search_string[:size], param_array[:size])
      else
        rooms = rooms.where(search_string[:size], param_array[:size])
      end

      return nil if rooms.nil?
    end

    if not param_array[:room_number].nil? and not param_array[:room_number].empty?

      if rooms.nil?
        rooms = Room.where(search_string[:room_number], param_array[:room_number])
      else
        rooms = rooms.where(search_string[:room_number], param_array[:room_number])
      end

      return nil if rooms.nil?
    end

    #reservations = Reservation.where("room_number LIKE ? and start_time > ? and end_time < ?", room_number, currentTime, currentTime.end_of_day)

    #return null if reservations.nil?

    @roomDict = {}
    @reservedSlotDict = {}

    if  params[:building].empty? and  params[:size].empty? and  params[:room_number].empty?
      rooms = Room.all
    end

    rooms.each do |room|
      reservations = room.reservations.where("start_time > ? and end_time < ?", currentTime, currentTime.end_of_day)

      reservedSlots = reservations.map {|a| [a.start_time, a.end_time] }

      reservedSlots << [currentTime.end_of_day, currentTime.end_of_day]
      reservedSlots.sort! { |a,b| a.at(0) <=> b.at(0)}
      prev = currentTime
      availableSlots = []
      reservedSlots.each do |reserved|
        if reserved[0] > prev
          availableSlots << [prev, reserved[0]]
        end
        prev = reserved.at(1)
      end

      @roomDict[room] = availableSlots
      if reservedSlots.length > 1
        @reservedSlotDict[room] = reservedSlots[0..-2]
      end
    end

    if not param_array[:status].nil? and param_array[:status] == "Booked"
      return @reservedSlotDict
    else
      return @roomDict
    end
  end

  def searchFilter
    status_code = isMemberLoggedIn(false)
    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end

    search_query_string = {}

    unless params[:room_number].nil?
      search_query_string[:room_number] = "room_number LIKE ?"
    end
    unless params[:building].nil?
      search_query_string[:building] ="building LIKE ?"
    end
    unless params[:status].nil?
      search_query_string[:status] = "status LIKE ?"
    end
    unless params[:size].nil?
      search_query_string[:size] =  "size LIKE ?"
    end

    @roomDicts = getAvailabilityOfRoom(params, search_query_string)

    @displayBookedFrom = true if not params[:status].nil? and params[:status] == "Booked" else false

    render :searchResults
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    status_code = isMemberLoggedIn

    if status_code == false
      flash[:notice] = "Please login before you continue"
      render members_signin_path and return
    end

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
