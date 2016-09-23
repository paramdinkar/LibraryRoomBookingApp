class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]

  # GET /reservations
  # GET /reservations.json
  def index
    @reservations = Reservation.all
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
    @room = Room.all
  end

  #Form hits this action while submitting building information. Afetr submit building, it calls createreservation action
  def newreservation
    @reservation = Reservation.new
    @rooms = Room.new
    @room = Room.all
    render 'reservations/newreservation'
  end

  def managereservation
    #@room = Room.where("status LIKE ?", "Reserved")
    @member = Member.where("email LIKE ?", session[:email]).first
    @reservations = @member.reservations
    render 'reservations/managereservation'
end

  def createreservation
    @room = Room.all
    @reservation = Reservation.new
    @room1 = Room.where("building LIKE ?", params[:building])
    @room_list = @room1.collect {|room| room.room_number}
    render 'reservations/new'
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(reservation_params)
    @room = Room.where("room_number LIKE ?", @reservation.room_number)
    @member = Member.where("email LIKE ?", session[:email])
    @current_reservations = Reservation.where("room_number LIKE ? and ? <= end_time and start_time <= ? ", @reservation.room_number,
    @reservation.start_time, @reservation.end_time)
    if not @current_reservations.nil? and not @current_reservations.empty?
      puts @current_reservations.first.start_time
      puts @current_reservations.first.room_number
      flash[:notice] = "This room is not available at this time. Conflicts with other reservation which starts at #{@current_reservations.first.start_time} "
      render 'reservations/newreservation' and return
    end
    puts @member.first.name
    puts @member.first.id
    puts "******************************************"
    if @reservation.start_time > @reservation.end_time
      flash[:notice] = "ERROR: Booking start  time can't be greater than end time"
      render 'reservations/newreservation' and return
    end

    if @reservation.start_time + 2.hours < @reservation.end_time
      flash[:notice] = "ERROR : Reservation can be made only for 2 hours at a time"
      render 'reservations/newreservation' and return
    end

    #User can only reserve one room at a perticular date and time without extra permission from admin
    @user_reservations = Reservation.where("members_id == ? and ? <= end_time and start_time <= ? ", @member.first.id,
                                              @reservation.start_time, @reservation.end_time)
    if not @user_reservations.empty? and @member.first.isMultipleReservationAllowed != "Yes"
      flash[:notice] = "ERROR : You already have reservation from #{@reservation.start_time} to #{@reservation.end_time} .
      You can't book room during this time interval. Contact Administrator if you want to book multiple rooms with
      overlapping time intervals"
      render 'reservations/newreservation' and return
    end

    @reservation.room_id = @room.first.id
    @member.first.reservations << @reservation
    SendEmail.reservation_email(@member.first, @reservation).deliver
    respond_to do |format|
      if @member.first.save
        format.html { redirect_to @reservation, notice: 'Reservation was successfully created.' and return }
        format.json { render :show, status: :created, location: @reservation }
      else
        format.html { render :new }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { render :show, status: :ok, location: @reservation }
      else
        format.html { render :edit }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation.destroy
    respond_to do |format|
      format.html { redirect_to reservations_url, notice: 'Reservation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:room_number, :start_time, :end_time, :status)
    end
end
