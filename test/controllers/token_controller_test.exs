defmodule Wall.TokenControllerTest do
  use Wall.ConnCase

  setup %{conn: conn} do
    token = Phoenix.Token.sign(@endpoint, "user socket", "1")
    {:ok, conn: put_req_header(conn, "accept", "application/json"), token: token}
  end

  test "generates a new token for a project", %{conn: conn, token: token} do
    Repo.insert(%Wall.Project{id: 1, name: "project 1"})
    conn = get conn, project_token_path(conn, :show, "123"), token: token
    token = json_response(conn, 200)["token"]
    assert Wall.Token.verify(token) == {:ok, "123"}
  end
end
