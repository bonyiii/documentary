require 'spec_helper'

RSpec.describe Documentary::Params do
  let(:controller_class) { TestController }
  subject { controller_class }

  describe '#params mock' do
    it 'should have benn called' do
      expect(subject).to receive(:params)
      subject.params :show do
        optional(:type)
        required(:vintage)
      end
    end
  end

  describe '#params' do
    context 'when params defined below method' do
      # Eg:
      # def index
      # end
      # params :index do
      #   required :name
      # end
      before do
        expect(Documentary::ParamBuilder).to receive(:build) do
          { type: 'Foo', vintage: 'Bar' }
        end
        expect(subject).to receive(:public_method_defined?).and_return(true)
      end

      after { TestController.instance_eval { @store.delete(:edit) } }

      it 'should good to go' do
        expect { subject.params(:edit) }.not_to raise_error
      end

      context 'params method should be called with an action first time per action' do
        before { subject.params(:edit) }
        it { expect(subject.params[:edit][:type]).to eq('Foo') }
      end
    end

    context 'when params is defined above method' do
      # Eg:
      # params :index do
      #   required :name
      # end
      # def index
      # end
      before { expect(subject).to receive(:public_method_defined?).and_return(false) }

      it 'should blow up' do
        expect do
          subject.params(:edit)
        end.to raise_error Documentary::PublicMethodMissing, "'TestController' has no public instance method 'edit' defined!"
      end
    end

    context 'when the method described by params is not exists' do
      it 'should raise error' do
        expect { subject.params(:edit) }.to raise_error Documentary::PublicMethodMissing, "'TestController' has no public instance method 'edit' defined!"
      end
    end

    context 'without nested params' do
      let(:year_desc) { 'Year of the vintage' }

      before do
        subject.params :show do
          optional(:type)
          required(:vintage, type: Integer, desc: 'Year of the vintage')
        end
      end

      it 'should set params' do
        expect(subject.params).to be
      end

      it { expect(subject.params[:show][:vintage]).to be }
      it { expect(subject.params[:show][:vintage][:type]).to eq(Integer.to_s) }
      it { expect(subject.params[:show][:vintage][:desc]).to eq(year_desc) }
      it { expect(subject.params[:show][:vintage][:required]).to eq(true) }
      it { expect(subject.params[:show][:type][:required]).to eq(false) }
    end

    context 'with nested params' do
      let(:year_desc) { 'Year of the vintage' }

      before do
        subject.params :show do
          optional(:type)
          required(:vintage, type: Array) do
            required(:year, type: Integer, desc: 'Year of the vintage')
            optional(:month, type: Integer)
            optional(:day, type: Integer)
          end
        end
      end

      it { expect(subject.params).to be }
      it { expect(subject.params[:show][:vintage][:year][:type]).to eq(Integer.to_s) }
      it { expect(subject.params[:show][:vintage][:year][:desc]).to eq(year_desc) }
      it { expect(subject.params[:show][:vintage][:required]).to eq(true) }
      it { expect(subject.params[:show][:vintage][:type]).to eq(Array.to_s) }
      it { expect(subject.params[:show][:vintage][:year][:required]).to eq(true) }
      it { expect(subject.params[:show][:vintage][:day][:required]).to eq(false) }
    end

    context 'authorization' do
      subject { controller_class.new }

      it 'should raise error for invalid option' do
        expect do
          controller_class.params :show do
            optional(:type, not_defined: ->(controller) { controller.to_s })
          end
        end.to raise_error ArgumentError
      end

      context 'when only a single param which is not authorized present' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type, authorized: ->(controller) { false })
          end
        end

        it { expect(subject.authorized_params(:show)).not_to include(:type) }
        it { expect(subject.authorized_params(:edit)).not_to be }
      end

      context 'when two method defined, one with a single
               param which is not allowed for current user and
               another with a param which is allowed for anyone' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type, authorized: ->(controller) { false })
          end

          # Set up edit method here
          expect(Documentary::ParamBuilder).to receive(:build) do
            store = Documentary::Store.new
            store[:type] = 'Foo'
            store[:vintage] = 'Bar'
            store
          end
          expect(controller_class).to receive(:public_method_defined?).and_return(true)
          controller_class.params(:edit)
        end

        after { controller_class.instance_eval { @store.delete(:edit) } }

        it { expect(subject.authorized_params(:show)).not_to include(:type) }
        it { expect(subject.authorized_params(:edit)).to include(:type) }
      end

      context 'without nested params' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type, authorized: ->(controller) { false })
            required :name
          end
        end

        it { expect(subject.authorized_params(:show)).not_to include(:type) }
      end

      context 'with nested params' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type)
            required(:vintage, type: Array) do
              required(:year, type: Integer, desc: 'Year of the vintage', authorized: ->(controller) { false })
              optional(:month, type: Integer)
            end
          end
        end

        it { expect(subject.authorized_params(:show)[:vintage]).not_to include(:year) }
        it { expect(subject.authorized_params(:show)[:vintage]).to include(:month) }
        it { expect(subject.authorized_params(:show)).to include(:type) }
        it { expect(subject.authorized_params(:edit)).not_to be }
      end

      context 'with a lambda which uses the controller' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type, authorized: ->(controller) { controller.allowed? })
            required :name
          end
        end

        context 'when params is allowed' do
          before { expect(subject).to receive(:allowed?).and_return(true) }
          it { expect(subject.authorized_params(:show)).to include(:type) }
          it { expect(subject.authorized_params(:show)[:type]).not_to include(:if) }
        end

        context 'when params is not allowed' do
          before { expect(subject).to receive(:allowed?).and_return(false) }
          it { expect(subject.authorized_params(:show)).not_to include(:type) }
        end
      end

      context 'with a proc which does not use the controller' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type, authorized: proc { true })
            required :name
          end
        end

        context 'when params is allowed' do
          it { expect(subject.authorized_params(:show)).to include(:type) }
        end
      end

      context 'with a symbol which uses the controller' do
        let(:year_desc) { 'Year of the vintage' }

        before do
          controller_class.params :show do
            optional(:type, authorized: :allowed?)
            required :name
          end
        end

        context 'when params is allowed' do
          before { expect(subject).to receive(:allowed?).and_return(true) }
          it { expect(subject.authorized_params(:show)).to include(:type) }
        end

        context 'when params is not allowed' do
          before { expect(subject).to receive(:allowed?).and_return(false) }
          it { expect(subject.authorized_params(:show)).not_to include(:type) }
        end
      end
    end
  end
end
