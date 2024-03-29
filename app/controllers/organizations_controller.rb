class OrganizationsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]

  def create
  	@organization = Organization.new(orga_params)
  	if @organization.save
  		flash[:success] = "Organization created. Members can now join via the organization page, or during signup."
  		redirect_to @organization
  	else
  		render 'new'
  	end
  end

  def new	
  	@organization = Organization.new
  end

  def destroy
    Organization.find(params[:id]).destroy
    flash[:success] = "Organization deleted"
    redirect_to organizations_url
  end

  def show
  	@organization = Organization.find(params[:id])
    joiners
  	# Make sure only public events/members are shown on public pages
    #users = @organization.users.paginate(page: params[:page])
    #@events = @organization.events.paginate(page: params[:page])
  end

  def index
  	@organizations = Organization.paginate(page: params[:page])
  end

  def joiners 
    @organization = Organization.find(params[:id])
    @users = @organization.joiners.paginate(page: params[:page])
    #render 'show_members'
  end

  def attenders
    @organization = Organization.find(params[:id])
    @events = @organization.attenders.paginate(page: params[:page])
    render 'show_org_events'
  end


private
	
	def orga_params
		params.require(:organization).permit(:name, :description)
	end


end
