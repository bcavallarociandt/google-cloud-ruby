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


require 'sinatra'
require 'stackdriver'
require 'grpc'

Google::Cloud.configure do |config|
  config.logging.log_name = "google-cloud-ruby_integration_test"
end

#######################################
# Setup Middlewares
use Google::Cloud::ErrorReporting::Middleware
use Google::Cloud::Logging::Middleware


# Set :raise_errors to expose error message in production environment
set :raise_errors, true
set :bind, "0.0.0.0"
set :port, 8080


get '/' do
  "Test classic sinatra app up and running"
end

get '/_ah/health' do
  "Success"
end

get '/test_error_reporting' do
  error_toke = params[:token]
  raise StandardError, "Test error from sinatra classic: #{error_toke}"
end

get '/test_logging' do
  log_token = params[:token]
  logger.info "Test log entry from classic sinatra #{log_token}"
  log_token.to_s
end

get '/test_logger' do
  {
    logger_class: logger.class.to_s,
    writer_class: logger.writer.class.to_s,
    monitored_resource: {
      type: logger.resource.type,
      labels: logger.resource.labels
    }
  }.to_json
end
