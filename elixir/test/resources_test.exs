defmodule ResourcesTest do
  use ExUnit.Case
  doctest Resources

  # create table objects (id int, value text);

  test "http server starts" do
    Resources.serve()
    response = HTTPoison.get!("http://localhost:3000")
    assert response.status_code == 200
    assert response.body == "OK\n"
  end

  test "save object" do
    Resources.serve()
    body = "{\"id\": 123, \"value\": \"123123123\"}"
    response = HTTPoison.post!("http://localhost:3000/objects", body)
    assert response.status_code == 201
    assert response.body == "ok"
  end

  test "fetch object" do
    Resources.serve()
    body = "123123123"
    response = HTTPoison.get!("http://localhost:3000/objects/123")
    assert response.status_code == 200
    assert response.body == body
  end

end
