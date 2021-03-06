# Copyright 2017, Google Inc. All rights reserved.
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
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Google Cloud Speech API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Google Cloud Speech API][Product Documentation]: Google Cloud Speech API.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Google Cloud Speech API.](https://console.cloud.google.com/apis/api/speech)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-speech
    # ```
    #
    # ### Preview
    # #### SpeechClient
    # ```rb
    # require "google/cloud/speech/v1"
    #
    # speech_client = Google::Cloud::Speech::V1::SpeechClient.new
    # language_code = "en-US"
    # sample_rate_hertz = 44100
    # encoding = :FLAC
    # config = {
    #   language_code: language_code,
    #   sample_rate_hertz: sample_rate_hertz,
    #   encoding: encoding
    # }
    # uri = "gs://gapic-toolkit/hello.flac"
    # audio = { uri: uri }
    # response = speech_client.recognize(config, audio)
    # ```
    #
    # ### Next Steps
    # - Read the [Google Cloud Speech API Product documentation][Product Documentation] to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md) to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/speech
    #
    module Speech
      # rubocop:enable LineLength

      ##
      # # Google Cloud Speech API Contents
      #
      # | Class | Description |
      # | ----- | ----------- |
      # | [SpeechClient][] | Google Cloud Speech API. |
      # | [Data Types][] | Data types for Google::Cloud::Speech::V1 |
      #
      # [SpeechClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-speech/latest/google/cloud/speech/v1/v1/speechclient
      # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-speech/latest/google/cloud/speech/v1/v1/datatypes
      #
      module V1
      end
    end
  end
end

require "google/cloud/speech/v1/speech_client"
