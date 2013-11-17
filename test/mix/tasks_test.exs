Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.VcrTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  @dummy_path  "tmp/vcr_tmp/"
  @dummy_file  "dummy.json"
  @dummy_file2 "dummy2.json"

  setup_all do
    File.mkdir_p!(@dummy_path)
    :ok
  end

  test "mix vcr" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.run([])
    end) =~ %r/Showing list of cassettes/
  end

  test "mix vcr.custom" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Custom.run([])
    end) =~ %r/Showing list of cassettes/
  end

  test "mix vcr.delete" do
    File.touch!(@dummy_path <> @dummy_file)
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Delete.run(["--dir", @dummy_path, @dummy_file])
    end) =~ %r/Deleted dummy.json./
    assert(File.exists?(@dummy_path <> @dummy_file) == false)
  end

  test "mix vcr.delete with --interactive option" do
    File.touch!(@dummy_path <> @dummy_file)
    assert capture_io("y\n", fn ->
      Mix.Tasks.Vcr.Delete.run(["-i", "--dir", @dummy_path, @dummy_file])
    end) =~ %r/delete dummy.json?/
    assert(File.exists?(@dummy_path <> @dummy_file) == false)
  end

  test "mix vcr.delete with --all option" do
    File.touch!(@dummy_path <> @dummy_file)
    File.touch!(@dummy_path <> @dummy_file2)

    assert capture_io("y\n", fn ->
      Mix.Tasks.Vcr.Delete.run(["-a", "--dir", @dummy_path, @dummy_file])
    end) =~ %r/Deleted dummy.json./

    assert(File.exists?(@dummy_path <> @dummy_file) == false)
    assert(File.exists?(@dummy_path <> @dummy_file2) == false)
  end

  test "mix vcr.delete with invalid file" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Delete.run(["--dir", @dummy_path])
    end) =~ %r/invalid parameter is specified/
  end

  test "mix vcr.custom logics" do
    assert Mix.Tasks.Vcr.Check.initialize([dir: "test1,test2"]) ==
       ExVCR.Checker.new(dirs: ["test1", "test2"])

    assert Mix.Tasks.Vcr.Check.initialize([]) ==
       ExVCR.Checker.new(dirs: ["fixture/vcr_cassettes", "fixture/custom_cassettes"])
  end
end