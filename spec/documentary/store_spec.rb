require 'spec_helper'

class TestController
  extend Documentary::Params
  def show; end
end

RSpec.describe Documentary::Store do
  context 'when store object defined directly' do
    describe '#to_strong' do
      subject { store.to_strong }

      let(:store) { described_class.new }

      before do
        store[:name] = described_class.new
        store[:name][:type] = String.to_s
        store[:name][:desc] = 'Name attribute'
      end

      context 'with multiple level nested params' do
        it { expect(subject).to eq([:name]) }
      end
    end
  end

  context 'when store object is used in a controller' do
    describe '#to_strong' do
      let(:action) { :show }
      before { TestController.params(action, &params) }
      subject { TestController.params[action].to_strong }

      context 'with a params which conflicts with predefined key' do
        let(:params) do
          proc {
            optional(:type)
          }
        end

        it { expect(subject).to eq(%i[type]) }
      end

      context 'with multiple flat params' do
        let(:params) do
          proc {
            optional(:type, type: String)
            optional(:desc)
            optional(:required)
            required(:name, type: String)
          }
        end

        it { expect(subject).to eq(%i[type desc required name]) }
      end

      context 'with flat single and vector params' do
        let(:params) do
          proc {
            optional(:name)
            required(:emails, type: Array)
          }
        end

        it { expect(subject).to eq([:name, { emails: [] }]) }
      end

      context 'with single level nested params' do
        let(:params) do
          proc {
            required(:family) do
              required(:name, type: String, desc: 'Family/Name any permitted scalar value')
            end
          }
        end

        it { expect(subject).to eq([{ family: [:name] }]) }
      end

      context 'with multiple level nested params' do
        let(:params) do
          proc {
            optional(:name)
            required(:emails, type: Array, desc: 'Array of any permitted scalar values see Strong Parameters Docs')
            required(:friends, type: Array) do
              required(:name, type: String, desc: 'Any permitted scalar value')
              required(:family) do
                required(:name, type: String, desc: 'Family/Name any permitted scalar value')
              end
              optional(:hobbies, type: Array)
            end
          }
        end

        it {
          expect(subject).to eq([:name, { emails: [] },
                                 friends: [:name,
                                           { family: [:name] }, { hobbies: [] }]])
        }
      end
    end
  end
end
