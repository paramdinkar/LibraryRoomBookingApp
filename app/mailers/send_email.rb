class SendEmail < ActionMailer::Base
  default from: "lib90.ncsu@gmail.com"
  def reservation_email(user, reservation)
      @user = user
      @reservation = reservation
      @url = "http://www.google.com/"
      mail(to: @user.email, subject: 'NCSU Libraries room reservation')
  end
end
