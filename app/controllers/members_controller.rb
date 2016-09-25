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

  def searchRooms
    render :search
  end

  def getAvailabilityOfRoom(param_array, search_string)
    currentTime = DateTime.now
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

      if reservations.nil?
        rooms = Room.where(search_string[:room_number], param_array[:room_number])
      else
        rooms = rooms.where(search_string[:room_number], param_array[:room_number])
      end

      return nil if rooms.nil?
    end

    #reservations = Reservation.where("room_number LIKE ? and start_time > ? and end_time < ?", room_number, currentTime, currentTime.end_of_day)

    #return null if reservations.nil?

    @roomDict = {}

    if  params[:building].empty? and  params[:size].empty? and  params[:room_number].empty? and params[:status]
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
    end

    return @roomDict
  end

  def searchFilter
    search_query_string = {}

    unless params[:room_number].nil?
      search_query_string[:room_number] = "room_number LIKE ?"
    end
    unless params[:building].nil?
      search_query_string[:building] ="building LIKE ?"
    end
    #unless params[:status].nil?
    #  search_query_string[:status] = "status LIKE ?"
    #end
    unless params[:size].nil?
      search_query_string[:size] =  "size LIKE ?"
    end

    @roomDicts = getAvailabilityOfRoom(params, search_query_string)

    render :searchResults
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
