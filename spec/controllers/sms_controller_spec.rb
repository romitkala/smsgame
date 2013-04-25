require 'spec_helper'

describe SmsController do
  before do
    @client = mock('client')
    @messages = mock('message')
    @messages.stub(:create)
    @client.stub_chain(:account, :sms, :messages).and_return(@messages)
    Twilio::REST::Client.stub(:new).and_return(@client)
  end

  context "first message for registration of the participant" do
    context "new participant" do
      it "should create a new participant" do
        post 'create', {:From => "123456", :Body => "John"}
        body = JSON.parse response.body
        Participant.find_by_username('John').should_not be_nil
        body["participant"]["token"].should_not be_nil
      end

      it "should send a confirmation sms back to the user with the token" do
        mock_participant = mock('participant', :token => 123, :to_json => {})
        mock_participant.stub(:save).and_return(true)
        Participant.stub(:new).and_return(mock_participant)
        @messages.should_receive(:create).with({:body=>123, :to=>"123456", :from=>"+18585003433"})
        post 'create', {:From => "123456", :Body => "Jane"}
      end
    end

    context "username must be valid and unique" do
      it "should not create new participant with the same username" do
        Participant.create(:username => "John", :mobile_number => "6543")
        post 'create', {:From => "3456", :Body => "John"}
        response.status.should == 422
      end

      it "should send a error sms back to the user with the token" do
        mock_participant = mock('participant', :token => 123, :to_json => {})
        mock_participant.stub(:save).and_return(false)
        Participant.stub(:new).and_return(mock_participant)
        @messages.should_receive(:create).with({:body=>"participant username must be unique", :to=>"123456", :from=>"+18585003433"})
        Participant.create(:username => "John", :mobile_number => "6543")
        post 'create', {:From => "123456", :Body => "John"}
      end

      it "should not create new participant if the username is in the invalid format" do
        post 'create', {:From => "3456", :Body => "1234sdfsdfds"}
        response.status.should == 422
        Participant.find_by_username('1234sdfsdfds').should be_nil
      end
    end
  end

  context "voting" do
    it "should add a vote if user token is valid" do
      participant = Participant.create(:username => "John", :mobile_number => "6543")
      post 'create', {:From => '1234', :Body => participant.token}
      Vote.find_by_participant_id(participant.id).should_not be_nil
    end

    it "should send a thanks sms back to the user" do
      mock_participant = mock('participant',:username => 'joe', :token => 123, :to_json => {})
      mock_participant.stub_chain(:votes, :create)
      Participant.stub(:find_by_token).and_return(mock_participant)
      @messages.should_receive(:create).with({:body=>"Thanks! Your Vote for: joe has been registered", :to=>"1234", :from=>"+18585003433"})
      post 'create', {:From => '1234', :Body => 9878}
    end

    it "should return an error if token is not a number" do
      post 'create', {:From => '1234', :Body => "=$%&*&^%$"}
      response.status.should == 422
    end

    it "should send a invalid token sms back to the user" do
      mock_participant = mock('participant',:username => 'joe', :token => 123, :to_json => {})
      Participant.stub(:find_by_token).and_return(nil)
      @messages.should_receive(:create).with({:body=>"invalid token", :to=>"1234", :from=>"+18585003433"})
      post 'create', {:From => '1234', :Body => "=$%&*&^%$"}
    end

    it "should return an error if token doesn't belong to any user" do
      post 'create', {:From => '1234', :Body => "9999999"}
      response.status.should == 422
    end
  end
end
