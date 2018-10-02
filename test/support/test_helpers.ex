defmodule Timber.Exceptions.TestHelpers do
  defmacro skip_min_elixir_version(version) do
    quote do
      unless(Version.match?(System.version(), "~> #{unquote(version)}")) do
        @tag :skip
      end
    end
  end

  # This replicates functions that are defined in Timber.TestHelpers but are
  # defined here as well for the purposes of 
  def event_entry_to_log_entry({level, _, {Logger, message, ts, metadata}}) do
    Timber.LogEntry.new(ts, level, message, metadata)
  end

  def event_entry_to_msgpack(entry) do
    log_entry = event_entry_to_log_entry(entry)

    map =
      log_entry
      |> Timber.LogEntry.to_map!()
      |> Map.put(:message, IO.chardata_to_string(log_entry.message))

    Msgpax.pack!([map])
  end

  def add_in_memory_logger_backend(pid) when is_pid(pid) do
    {:ok, _pid} = Logger.add_backend(Timber.LoggerBackends.InMemory)
    Logger.configure_backend(Timber.LoggerBackends.InMemory, callback_pid: pid)
    :ok = Logger.remove_backend(:console)

    ExUnit.Callbacks.on_exit(fn ->
      :ok = Logger.remove_backend(Timber.LoggerBackends.InMemory)
      {:ok, _pid} = Logger.add_backend(:console)
    end)
  end
end
