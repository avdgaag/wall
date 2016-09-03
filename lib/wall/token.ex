defmodule Wall.Token do
  @token_name "token"

  @doc """
  Encrypt and Base64-encode a given message.
  """
  def sign(message) do
    Wall.Endpoint
    |> Phoenix.Token.sign(@token_name, message)
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Base64-decode and decrypt a string that was generated using Wall.Token.sign.
  """
  def verify(encoded_message) do
    with {:ok, encrypted_message} <- Base.url_decode64(encoded_message, padding: false),
         {:ok, message} <- Phoenix.Token.verify(Wall.Endpoint, @token_name, encrypted_message)
    do
      {:ok, message}
    end
  end
end
