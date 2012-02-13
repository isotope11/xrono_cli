module Xcli
  class Cli < Thor
    include CommandLineReporter
    include HTTParty

    no_tasks do
      def self.configuration
        @configuration ||= Xcli::Configuration.new
      end

      def configuration
        self.class.configuration
      end
    end

    base_uri configuration.url

    desc 'clients', 'list clients'
    method_option :initials, :type => :string
    def clients
      report(:message => 'Loading Clients...', :complete => '', :indent_size => 8) do
        require_login
        clients = self.class.get("/api/v1/clients", :body => {:auth_token => @token, :initials => options[:initials]})
        table(:border => true) do
          row do
            column('Initials', :width => 20)
            column('NAME', :width => 20)
          end
          clients.each do |client|
            row do
              column(client["initials"])
              column(client["name"])
            end
          end
        end
      end
    end

    desc 'projects', 'list projects'
    method_option :client_initials, :type => :string
    def projects
      report(:message => 'Loading projects...', :complete => '', :indent_size => 8) do
        require_login
        projects = self.class.get("/api/v1/projects", :body => {:auth_token => @token, :client_initials => options[:client_initials]})
        table(:border => true) do
          row do
            column('NAME', :width => 20)
          end
          projects.each do |project|
            row do
              column(project["name"])
            end
          end
        end
      end
    end

    desc 'ticket', 'show current ticket based on git repo and branch'
    def ticket
      report(:message => 'Loading current ticket...', :complete => '', :indent_size => 8) do
        show_current_ticket
      end
    end

    desc 'new_ticket', 'create new ticket based on git repo and branch'
    method_options :estimated_hours => :numeric, :name => :string, :message => :string
    def new_ticket
      report(:message => 'Creating new ticket...', :complete => '', :indent_size => 8) do
        require_login
        status = self.class.post("/api/v1/tickets", :body => {:ticket => {:project_id => current_project["id"], :estimated_hours => options[:estimated_hours], :description => options[:message], :git_branch => current_branch_name, :name => options[:name]}, :auth_token => @token})
        show_current_ticket
      end
    end

    desc 'enter_time', 'enter time to current ticket based on git repo and branch'
    method_options :hours => :numeric, :message => :string
    def enter_time
      report(:message => 'Creating work unit...', :complete => '', :indent_size => 8) do
        require_login
        status = self.class.post("/api/v1/work_units", :body => {:work_unit => {:ticket_id => current_ticket["id"], :hours => options[:hours], :hours_type => "Normal", :description => options[:message], :scheduled_at => Time.now.to_s}, :auth_token => @token})
        if status["success"]
          puts "Time Entered"
        else
          puts "It didn't work"
        end
      end
    end

    desc 'status', 'show information about the current user'
    def status
      report(:message => 'Loading status...', :complete => '', :indent_size => 8) do
        require_login
        table(:border => true) do
          row do
            column('USERNAME', :width => 20)
            column('CURRENT HOURS', :width => 20)
            column('OFFSET', :width => 20)
          end
          row do
            column(configuration.email)
            column(@current_hours)
            column(@offset)
          end
        end
      end
    end

    private

    def current_branch_name
      r = Grit::Repo.new('.')
      r.head.name
    end

    def git_repo_url
      r = Grit::Repo.new('.')
      r.config["remote.origin.url"]
    end

    def require_login
      login unless @token
    end

    def login
      login_response = self.class.post("/api/v1/tokens", :body => {:email => configuration.email, :password => configuration.password})
      @token          = login_response["token"]
      @current_hours  = login_response["current_hours"]
      @offset         = login_response["offset"]
    end

    def current_ticket
      return @current_ticket if @current_ticket
      require_login
      @current_ticket = self.class.get("/api/v1/tickets", :body => {:auth_token => @token, :repo_url => git_repo_url, :branch => current_branch_name}).first
    end

    def current_project
      return @current_project if @current_project
      require_login
      @current_project = self.class.get("/api/v1/projects", :body => {:auth_token => @token, :git_repo_url => git_repo_url}).first
    end

    def show_current_ticket
      table(:border => true) do
        row do
          column('NAME', :width => 30)
          column('ESTIMATED HOURS', :width => 20)
          column('HOURS WORKED', :width => 20)
          column('PERCENTAGE COMPLETE', :width => 20)
        end
        row do
          column(current_ticket["name"])
          column(current_ticket["estimated_hours"])
          column(current_ticket["hours"])
          column("#{current_ticket["percentage_complete"].to_s}%")
        end
      end
    end
  end
end
