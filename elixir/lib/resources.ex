defmodule Resources do
  require Logger

  defmodule Index do
    def init(req, state), do: {:ok, :cowboy_req.reply(200, %{}, "OK\n", req), state}
  end

  defmodule Object do
    @derive [Poison.Encoder]
    defstruct [:id, :value]
  end

  defmodule Objects do
    def get_db_connection() do
      {:ok, pid} = Postgrex.start_link(
        hostname: Resources.Config.db_host,
        database: Resources.Config.db_name,
        username: Resources.Config.db_user,
        password: Resources.Config.db_pass)
      pid
    end

    def init(req, state) do
      case req.method do
        "POST" ->
          db_pid            = get_db_connection()
          {:ok, body, req1} = :cowboy_req.read_body(req)
          object            = Poison.decode!(body, as: %Object{})
          result            = Postgrex.query!(db_pid,
            "insert into objects (id, value) values ($1, $2)",
            [object.id, object.value])
          {:ok, :cowboy_req.reply(201, %{}, "ok", req1), state}
        "GET" ->
          db_pid    = get_db_connection()
          text_id   = :cowboy_req.binding(:id, req)
          {id, etc} = Integer.parse(text_id)
          result    = Postgrex.query!(db_pid, "select value from objects where id = $1", [id])
          [value]   = Enum.at(result.rows, 0)
          {:ok, :cowboy_req.reply(200, %{}, value, req), state}
        _ ->
          {:ok, :cowboy_req.reply(400, %{}, "bad request", req), state}
      end
    end
  end

  defmodule Config do
    def routes do
      [ {"/",              Index,   []},
        {"/objects/[:id]", Objects, []} ]
    end
    def port,    do: 3000
    def db_host, do: "localhost"
    def db_name, do: "postgres"
    def db_user, do: "user"
    def db_pass, do: ""
  end

  def serve() do
    Application.ensure_all_started(:cowboy)
    Resources.App.start([], [])
  end

  defmodule App do
    def start(_start_type, _start_args) do
      routes   = [{:_, Resources.Config.routes}]
      dispatch = :cowboy_router.compile(routes)
      configs  = [{:port, Resources.Config.port}]
      :cowboy.start_clear(:resources, configs, %{
        :env         => %{:dispatch => dispatch},
        :middlewares => [:cowboy_router, :cowboy_handler]})
      Resources.Sup.start_link()
    end
  end

  defmodule Sup do
    use Supervisor

    def start_link() do
      {:ok, _sup} = Supervisor.start_link(__MODULE__, [], name: :supervisor)
    end

    def init(_) do
      processes = []
      {:ok, {{:one_for_one, 10, 10}, processes}}
    end
  end
end