require 'spec_helper'
require 'byebug'

#RSpec.describe Documentary::Swagger do
RSpec.describe Documentary::Store do
  let(:controller_class) { TestController }

  before { TestController.params(action, &params) }
  subject { TestController.params[action].to_swagger }

  describe '#swagger documentation' do

    context "GET show" do
      let(:action) { :show }
      let(:params) do
        proc {
          optional(:name)
          required(:emails, type: Array, desc: 'Array of any permitted scalar values see Strong Parameters Docs')
        }
      end

      it { expect(subject)
           .to eq({
                    parameters: [{
                                   name: "name",
                                   in: "formData",
                                   type: "string",
                                   required: false
                                 },{
                                   name: "emails",
                                   in: "formData",
                                   type: "array",
                                   description: 'Array of any permitted scalar values see Strong Parameters Docs',
                                   required: true
                                 }
                                ]
                  })
      }
    end
  end
end
#       {
# "swagger": "2.0",
# "info": {
#   "title": "API V1",
#   "version": "v1"
# },
# "paths": {
#   "/cars": {
#     "post": {
#       "summary": "Creates a car",
#       "tags": [
#         "Cars"
#       ],
#       "consumes": [
#         "application/json",
#         "application/xml"
#       ],
#       "parameters": [
#         {
#           "name": "blog",
#           "in": "body",
#           "schema": {
#             "type": "object",
#             "properties": {
#               "vintage": {
#                 "type": "string"
#               },
#               "type": {
#                 "type": "string"
#               }
#             },
#             "required": [
#               "vintage",
#               "content"
#             ]
#           }
#         }
#       ],
#       "responses": {
#         "201": {
#           "description": "car created"
#         },
#         "422": {
#           "description": "invalid request"
#         }
#       }
#     }
#   }
# }
