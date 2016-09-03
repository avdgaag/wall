defmodule Wall.EventControllerTest do
  use Wall.ConnCase

  alias Wall.Event

  setup %{conn: conn} do
    with {:ok, content} = File.read("test/fixtures/github.json"),
         params = Poison.decode!(content)
    do
      {:ok,
       conn: put_req_header(conn, "accept", "application/json"),
       params: params
      }
    end
  end

  test "shows an error when the token is not base64-encoded", %{conn: conn, params: params} do
    conn = post conn, event_path(conn, :create, "xyz"), params
    assert json_response(conn, 422)["error"] == "invalid token"
  end

  test "creates resource and confirms Github commit status hooks", %{conn: conn, params: params} do
    {:ok, project} = Repo.insert %Wall.Project{name: "My Project"}
    token = Wall.Token.sign(project.id)
    conn = post conn, event_path(conn, :create, token), params
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Event, %{topic: "ci"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, event_path(conn, :create, "invalid token"), event: %{}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "shows an error when the given token is invalid", %{conn: conn, params: params} do
    conn = post conn, event_path(conn, :create, "bla"), params
    assert json_response(conn, 422)["error"] == "invalid token"
  end

  test "shows an error when the token is invalid but the project does not exist", %{conn: conn, params: params} do
    token = Wall.Token.sign("invalid id")
    conn = post conn, event_path(conn, :create, token), params
    assert json_response(conn, 422)["errors"] == %{"project_id" => ["is invalid"]}
  end
end
