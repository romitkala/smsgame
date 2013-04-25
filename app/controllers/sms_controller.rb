require 'twilio-ruby'

class SmsController < ApplicationController
  # POST /sms
  # POST /sms.xml
  def create
    account_sid = 'AC70aee59d3a08b566d66016c127d641b9'
    auth_token = '84a589047447dd7c37e4c0262d888585'
    @client = Twilio::REST::Client.new account_sid, auth_token

    if params[:Body] =~ /^[A-Za-z][0-9A-Za-z_]*$/
      participant = Participant.new(:username => params[:Body], :mobile_number => params[:From])
      if participant.save
        send_sms participant.token, params[:From]
        render :json => participant.to_json
      else
        send_sms "participant username must be unique", params[:From]
        render :json => {}, :status => :unprocessable_entity
      end
    else
      participant = Participant.find_by_token(params[:Body])
      if participant
        participant.votes.create(params[:From])
        send_sms "Thanks! Your Vote for: #{participant.username} has been registered", params[:From]
        render :json => participant.to_json
      else
        send_sms "invalid token", params[:From]
        render :json => {}, :status => :unprocessable_entity
      end
    end
  end

  private
    def send_sms message, from
      @client.account.sms.messages.create(:body => message,
                                          :to => from,
                                          :from => "+18585003433")
    end
end
