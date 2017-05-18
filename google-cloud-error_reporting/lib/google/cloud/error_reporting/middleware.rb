# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module ErrorReporting
      ##
      # # Middleware
      #
      # Google::Cloud::ErrorReporting::Middleware defines a Rack Middleware
      # that can automatically catch upstream exceptions and report them
      # to Stackdriver Error Reporting.
      #
      class Middleware
        # A Google::Cloud::ErrorReporting::Project client used to report
        # error events.
        attr_reader :error_reporting

        ##
        # @private The Google Cloud project ID
        attr_reader :project_id

        ##
        # @private The Google Cloud keyfile path
        attr_reader :keyfile

        ##
        # Construct a new instance of Middleware.
        #
        # @param [Rack::Application] app The Rack application
        # @param [Google::Cloud::ErrorReporting::Project] error_reporting A
        #   Google::Cloud::ErrorReporting::Project client for reporting
        #   exceptions
        # @param [String] project_id Name of GCP project. Default to
        #   {Google::Cloud::ErrorReporting::Project.default_project}.
        #   Automatically discovered from GCP environments.
        # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
        #   file path the file must be readable.
        #   {Google::Cloud::ErrorReporting::Project.default_service_version}.
        #   Automatically discovered if on Google App Engine Flex.
        #
        # @return [Google::Cloud::ErrorReporting::Middleware] A new instance of
        #   Middleware
        #
        def initialize app, error_reporting: nil, project_id: nil, keyfile: nil
          require "rack"
          require "rack/request"
          @app = app
          load_config project_id: project_id, keyfile: keyfile

          @error_reporting = error_reporting ||
                             ErrorReporting.new(project: @project_id,
                                                keyfile: @keyfile)

          # Set module default client to reuse the same client. Update module
          # configuration parameters.
          ErrorReporting.class_variable_set :@@default_client, @error_reporting
        end

        ##
        # Implements the mandatory Rack Middleware call method.
        #
        # Catch all Exceptions from upstream and report them to Stackdriver
        # Error Reporting. Unless the exception's class is defined to be ignored
        # by this Middleware.
        #
        # @param [Hash] env Rack environment hash
        #
        def call env
          response = @app.call env

          # sinatra doesn't always raise the Exception, but it saves it in
          # env['sinatra.error']
          if env["sinatra.error"].is_a? Exception
            report_exception env, env["sinatra.error"]
          end

          response
        rescue Exception => exception
          report_exception env, exception

          # Always raise exception backup
          raise exception
        end

        ##
        # Report an given exception to Stackdriver Error Reporting.
        #
        # While it reports most of the exceptions. Certain Rails exceptions that
        # maps to a HTTP status code less than 500 will be treated as not the
        # app fault and ignored.
        #
        # @param [Hash] env Rack environment hash
        # @param [Exception] exception The Ruby exception to report.
        #
        def report_exception env, exception
          # Do not any exceptions that's specified by the ignore_classes list.
          return if configuration.ignore_classes.include? exception.class

          error_event = error_event_from_exception env, exception

          # If this exception maps to a HTTP status code less than 500, do
          # not report it.
          status_code = error_event.http_status.to_i
          return if status_code > 0 && status_code < 500

          error_reporting.report error_event
        end

        ##
        # Creates a {Google::Cloud::ErrorReporting::ErrorEvent} based on the
        # exception. Fill in the HttpRequestContext section of the ErrorEvent
        # based on the HTTP Request headers.
        #
        # When used in Rails environment. It replies on
        # ActionDispatch::ExceptionWrapper class to derive a HTTP status code
        # based on the exception's class.
        #
        # @param [Hash] env Rack environment hash
        # @param [Exception] exception Exception to convert from
        #
        # @return [Google::Cloud::ErrorReporting::ErrorEvent] The gRPC
        #   ErrorEvent object that's based on given env and exception
        #
        def error_event_from_exception env, exception
          error_event = ErrorReporting::ErrorEvent.from_exception exception

          # Inject service_context info into error_event object
          error_event.service_name = configuration.service_name
          error_event.service_version = configuration.service_version

          # Inject http_request_context info into error_event object
          rack_request = Rack::Request.new env
          error_event.http_method = rack_request.request_method
          error_event.http_url = rack_request.url
          error_event.http_user_agent = rack_request.user_agent
          error_event.http_referrer = rack_request.referrer
          error_event.http_status = http_status(exception)
          error_event.http_remote_ip = rack_request.ip

          error_event
        end

        private

        ##
        # Consolidate configurations from various sources. Also set
        # instrumentation config parameters to default values if not set
        # already.
        #
        def load_config project_id: nil, keyfile: nil
          @project_id = project_id ||
                        configuration.project_id ||
                        Cloud.configure.project_id ||
                        ErrorReporting::Project.default_project
          @keyfile = keyfile || configuration.keyfile || Cloud.configure.keyfile

          # Set defaults
          init_default_config

          # Ensure instrumentation configurations are aligned
          configuration.project_id = @project_id
          configuration.keyfile = @keyfile
        end

        ##
        # Fallback to default configuration values if not defined already
        def init_default_config
          configuration.service_name ||=
            ErrorReporting::Project.default_service_name
          configuration.service_version ||=
            ErrorReporting::Project.default_service_version
          configuration.ignore_classes = Array(configuration.ignore_classes)
        end

        ##
        # Helper method to derive HTTP status code base on exception class in
        # Rails. Returns nil if not in Rails environment.
        #
        # @param [Exception] exception An Ruby exception
        #
        # @return [Integer] A number that represents HTTP status code or nil if
        #   status code can't be determined
        #
        def http_status exception
          http_status = nil
          if defined?(ActionDispatch::ExceptionWrapper) &&
             ActionDispatch::ExceptionWrapper.respond_to?(
               :status_code_for_exception
             )
            http_status =
              ActionDispatch::ExceptionWrapper.status_code_for_exception(
                exception.class.name
              )
          end

          http_status
        end

        ##
        # @private Get Google::Cloud::ErrorReporting.configure
        def configuration
          Google::Cloud::ErrorReporting.configure
        end
      end
    end
  end
end
