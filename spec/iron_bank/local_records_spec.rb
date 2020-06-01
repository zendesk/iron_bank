# frozen_string_literal: true

RSpec.describe IronBank::LocalRecords do
  describe "::directory" do
    subject { described_class.directory }
    it { is_expected.to eq("./config/export") }
  end

  describe "::export" do
    subject(:export) { described_class.export }

    let(:fields) do
      [
        instance_double(IronBank::Describe::Field, name: "Id"),
        instance_double(IronBank::Describe::Field, name: "Status"),
        instance_double(IronBank::Describe::Field, name: "FileId")
      ]
    end

    let(:schema) { instance_double(IronBank::Describe::Object, fields: fields) }

    before do
      allow(IronBank::Schema).to receive(:for).with("Export").and_return(schema)

      IronBank::Export.with_schema
    end

    after do
      # NOTE: Resetting the instance variable here, else it seems to leak the
      #       `instance_double(IronBank::Describe::Object)` to the other
      #       examples.
      IronBank::Export.instance_variable_set :@schema, nil
    end

    context "local export directory does not exist" do
      before do
        allow(Dir).to receive(:exist?).and_return(false)
      end

      it "creates the local export directory if it does not exist" do
        stub_const("IronBank::LocalRecords::RESOURCE_QUERY_FIELDS", {})
        expect(FileUtils).to receive(:mkdir_p)

        export
      end
    end

    context "local export directory already exists" do
      before do
        allow(Dir).to receive(:exist?).and_return(true)
      end

      it "creates the local export directory if it does not exist" do
        stub_const("IronBank::LocalRecords::RESOURCE_QUERY_FIELDS", {})
        expect(FileUtils).not_to receive(:mkdir_p)

        export
      end
    end

    describe "for each resource to export" do
      let(:directory) { "./config/export" }

      let(:export_instance) do
        instance_double(IronBank::Export, status: "Completed", content: content)
      end

      let(:content) { "foo\nbar" }

      before do
        allow(IronBank::Export).to receive(:create).and_return(export_instance)

        allow(export_instance).to receive(:reload).and_return(export_instance)
      end

      it "creates a CSV file" do
        %w[
          Product
          ProductRatePlan
          ProductRatePlanCharge
          ProductRatePlanChargeTier
        ].each do |resource|
          file_path = File.expand_path("#{resource}.csv", directory)
          expect(File).to receive(:open).with(file_path, "w")
        end

        export
      end
    end

    context "for one resource" do
      let(:csv_file)       { instance_double(File) }
      let(:export_content) { +"fieldName\nrowValueA\nrowValueB" }

      let(:export_instance) do
        instance_double(IronBank::Export, id: "zuora-export-id", status: status)
      end

      before do
        stub_const(
          "IronBank::LocalRecords::RESOURCE_QUERY_FIELDS",
          "MyResource" => ["*"]
        )

        allow(FileUtils).to receive(:mkdir_p)

        allow(IronBank::Export).
          to receive(:create).
          with("select * from MyResource").
          and_return(export_instance)

        allow(export_instance).to receive(:reload).and_return(export_instance)

        # Faster tests by not allowing `sleep` to be called
        allow_any_instance_of(IronBank::LocalRecords).to receive(:sleep)
      end

      context "stuck on pending or processing status" do
        let(:status) { "Processing" }

        specify do
          expect { export }.
            to raise_error(IronBank::Error, "Export query attempts exceeded")
        end

        it "attempts 11 queries" do
          export
        rescue IronBank::Error
          expect(export_instance).to have_received(:reload).exactly(11).times
        end
      end

      context "failed export" do
        let(:status) { "Failed" }

        specify do
          expect { export }.to raise_error(
            IronBank::Error, "Export zuora-export-id has status Failed"
          )
        end
      end

      context "completed export" do
        let(:status)    { "Completed" }
        let(:file_path) { File.expand_path("MyResource.csv", directory) }
        let(:directory) { "./config/export" }

        before do
          allow(File).
            to receive(:open).
            with(file_path, "w").
            and_yield(csv_file)

          allow(export_instance).to receive(:content).and_return(export_content)

          allow(csv_file).to receive(:write).with(export_content)
        end

        it "write the export content to a CSV file" do
          export

          expect(csv_file).to have_received(:write)
        end
      end
    end
  end
end
