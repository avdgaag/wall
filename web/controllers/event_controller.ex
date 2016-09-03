defmodule Wall.EventController do
  use Wall.Web, :controller

  alias Wall.Event

  def create(conn, event_params) do
    with {:ok, token} <-  Base.decode64(event_params["token"]),
         {:ok, project_id} <- Phoenix.Token.verify(Wall.Endpoint, "token", token),
         changeset = Event.changeset(%Event{}, Map.put(event_params, "project_id", project_id)),
         {:ok, event} <- Repo.insert(changeset)
    do
      conn
      |> put_status(:created)
      |> render("show.json", event: event)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Wall.ErrorView, "errors.json", changeset: changeset)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid token"})
    end
  end
end
