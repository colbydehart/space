defmodule SpaceWeb.PageLive do
  use SpaceWeb, :live_view
  alias Phoenix.LiveView.Socket
  alias Phoenix.PubSub
  alias SpaceWeb.Presence
  @pubsub_topic ":space"

  @impl true
  @spec mount(map, map, Socket.t()) :: {:ok, Socket.t(), keyword()}
  def mount(_params, _session, socket) do
    PubSub.subscribe(Space.PubSub, topic(socket))

    # dev: remove
    Presence.track(self(), topic(socket), "Colby", %{pos: {1, 1}, color: "#0fe"})

    {:ok,
     assign(socket,
       users: [],
       name: "Colby",
       pos: {1, 1},
       color: "#0FE"
     ), temporary_assigns: [messages: []]}

    # end dev

    # {:ok, assign(socket, users: [], name: "Colby", pos: nil, messages: []),
    #  temporary_assigns: [messages: []]}
  end

  @impl true
  def handle_event("change_name", %{"name" => name, "color" => color}, socket) do
    # initial position
    pos = {rand_coord(), rand_coord()}
    Presence.track(self(), topic(socket), name, %{pos: pos, color: color})

    socket
    |> assign(name: name, pos: pos, color: color)
    |> put_flash(:info, "Welcome #{name}")
    |> noreply()
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    PubSub.broadcast(
      Space.PubSub,
      topic(socket),
      {:message, %{text: message, from: socket.assigns.name, id: UUID.uuid4()}}
    )

    socket
    |> noreply()
  end

  def handle_event("move", %{"key" => key}, socket) do
    pos = update_pos_by_input(socket.assigns.pos, key)

    self()
    |> Presence.update(
      topic(socket),
      socket.assigns.name,
      &Map.put(&1, :pos, pos)
    )

    PubSub.broadcast(Space.PubSub, topic(socket), :moved)

    socket
    |> assign(pos: pos)
    |> noreply()
  end

  # Presence events
  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    socket
    |> assign(users: get_users(socket))
    |> noreply()
  end

  # General Events
  def handle_info({:message, message}, socket) do
    socket
    |> assign(:messages, [message])
    |> noreply()
  end

  def handle_info(:moved, socket) do
    socket
    |> assign(users: get_users(socket))
    |> noreply()
  end

  # Utility 
  @spec topic(Socket.t()) :: String.t()
  defp topic(socket), do: socket.host_uri.host <> @pubsub_topic

  @spec noreply(term) :: {:noreply, term}
  defp noreply(term), do: {:noreply, term}

  @spec rand_coord() :: non_neg_integer
  def rand_coord(), do: Enum.random(0..9)

  @spec get_users(socket :: Phoenix.LiveView.Socket.t()) :: [Map]
  defp get_users(socket) do
    socket
    |> topic()
    |> Presence.list()
    |> Enum.map(fn {name, %{metas: metas}} ->
      metas
      |> List.first()
      |> Map.put(:name, name)
    end)
  end

  @type pos :: {non_neg_integer, non_neg_integer}
  @spec update_pos_by_input(pos :: pos, key :: binary()) :: pos
  def update_pos_by_input({x, y}, key) do
    case key do
      "ArrowDown" -> {x, min(y + 1, 9)}
      "ArrowUp" -> {x, max(y - 1, 0)}
      "ArrowLeft" -> {max(x - 1, 0), y}
      "ArrowRight" -> {min(x + 1, 9), y}
      _ -> {x, y}
    end
  end
end
