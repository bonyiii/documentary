require 'spec_helper'

class TestController
  extend Documentary::Params

  def show; end
end

RSpec.describe Documentary::Params do
  subject { TestController }

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
    context 'method defined before params call' do
      before do
        expect(Documentary::ParamBuilder).to receive(:build) do
          { type: 'Foo', vintage: 'Bar' }
        end
        expect(subject).to receive(:public_method_defined?).and_return(true)
      end

      it 'should good to go' do
        expect do
          subject.params(:edit)
        end.not_to raise_error
      end

      context 'params method should be called with an action first time per action' do
        before { subject.params(:edit) }
        it { expect(subject.params[:edit][:type]).to eq('Foo') }
      end
    end

    context 'method defined after params call' do
      before { expect(subject).to receive(:public_method_defined?).and_return(false) }

      it 'should blow up' do
        expect do
          subject.params(:edit)
        end.to raise_error Documentary::PublicMethodMissing, "'TestController' has no public instance method 'edit' defined!"
      end
    end

    context 'excpetions' do
      it 'should raise error if object not respond to action requested by params' do
        expect { subject.params(:edit) }.to raise_error Documentary::PublicMethodMissing, "'TestController' has no public instance method 'edit' defined!"
      end
    end

    context 'without nesting' do
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

    context 'nested params' do
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
  end
end
