class CompetencyStepsController < ApplicationController
	include Wicked::Wizard
  include AssessmentHelpers::Builder
  
  steps :indicators, :resources, :verify

	def show
    @competency = Competency.new(session[:competency])
    @resource_options = Resource.active.all
    if session[:upload]
      @resource_options = merge_uploaded_resources(@resource_options)
    end
    render_wizard
  end

  def update
  	#@competency = Competency.find(params[:competency_id])
  	#@competency.update_attributes(params[:competency])
  	#render_wizard @competency
    puts "SDLKJHFDSIUHQWEJBFEWILUBFSDKJBFSKDJLFBSLDKF"
    puts step
    puts params
    case step
    when :indicators
      session[:competency] = session[:competency].merge(params[:competency])
      @competency = Competency.new(session[:competency])
      redirect_to next_wizard_path
    when :resources
      session[:competency] = session[:competency].merge(params[:competency])
      @competency = Competency.new(session[:competency])
      redirect_to next_wizard_path
    when :verify
      @competency = Competency.new(session[:competency])
      build_competency(@competency)
      #render json: @competency.errors, status: :unprocessable_entity
      redirect_to @competency
        #if @competency.save
        #  redirect_to @competency, notice: 'Indicator was successfully created.'
        #else
        #  render json: @competency.errors, status: :unprocessable_entity
        #end
    end
  end

  def upload
    session[:competency] = nil
    session[:upload] = nil
    puts "SDGJKSHFJKDSHJKSDHFJKSDHFKJHSDLJKFHKSDFJKSDHFKJSHDFKJHSKJFHSDFKJHSJLDF"
    puts params
    @competency = Competency.new(competency_params)
    puts @competency.attributes
    session[:competency] = @competency.attributes

    indicator_info = Array.new
    indicator_file = params[:indicators]
    indicators = CSV.read(indicator_file.path, {:headers => true, :encoding => 'windows-1251:utf-8'})
    indicators.each do |indicator|
        indicator_info.push({level: indicator[0], description: indicator[1]})
    end
    session[:competency]["indicators_attributes"] = indicator_info

    resource_info = Array.new
    resources_file = params[:resources]
    resources = CSV.read(resources_file.path, {:headers => true, :encoding => 'windows-1251:utf-8'})
    resources.each do |resource|
        resource_info.push({resource_category: resource[0], name: resource[1], description: resource[2], link: resource[3]})
    end
    session[:resources] = resource_info

    session[:upload] = true

    redirect_to wizard_path(:indicators)
  end

  def competency_params
    params.require(:competency).permit(:name)
  end

  private
  def merge_uploaded_resources(resources)
    session[:resources].each do |resource|
      resources.push(Resource.new(name: resource[:name], description: resource[:description], link: resource[:link], resource_category: resource[:resource_category]))
    end
    return resources
    # options = Array.new
    # resources.each do |resource|
    #   options.push({id: resource.id, name: resource.name})
    # end
    # session[:resources].each do |resource|
    #   options.push({id: nil, name: resource[:name]})
    # end
    # return options
  end

end
