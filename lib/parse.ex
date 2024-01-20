defmodule Brex.Parser do
  use Rustler, otp_app: :brex, crate: "brex_parser"

  # When your NIF is loaded, it will override this function.
  def parse(_line), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def into_valid_chunks(_line, _leftover), do: :erlang.nif_error(:nif_not_loaded)
end
