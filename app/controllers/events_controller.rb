class EventsController < ApplicationController
	include EventsHelper
	before_action :signed_in_user, only: [:create, :destroy, :show]
	before_action :correct_user,   only: :destroy
	# before_action :signed_in_mod, only: [:create, :destroy]


	#should add show method for event(or have destroy go somewhere else but probably want to show individual events)

	def destroy
		@event.destroy
		redirect_to events_url
	end

	def create
		@event = Event.new(event_params)
		if @event.save
			flash[:success] = "Event Created"
			if current_user.ou_rels.count == 1
				organization = current_user.ou_rels.find_by(joiner_id: current_user.id)
				@event.orga_own(organization)	
			else	
			end 
			redirect_to events_url
		else
			@feed_items = []
			flash[:danger] = "Event failed to be created"
			redirect_to events_url
		end
	end

	def index
  	@events = Event.paginate(page: params[:page])
  	@event = Event.new
  end

   def show
  	@event = Event.find(params[:id])
  end

  def attenders
    @event = Event.find(params[:id])
    @users = @event.attenders.paginate(page: params[:page])
    render 'show_attend'
  end

  def correct_code
  	true
  end
  
  #updates event with a checkincode, thus unlocking it
  def update
  	@event = Event.find(params[:id])
  	@event.update_attribute(:checkincode, generate_checkincode)
  	redirect_to event_url
  end



private
	
	def event_params
		params.require(:event).permit(:title, :comment, :points, :start_time, :end_time)
	end

	def correct_user
		@event = current_user.events.find_by(id: params[:id])
		redirect_to event_url if @event.nil?
	end

end
