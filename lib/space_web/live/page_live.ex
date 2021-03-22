defmodule SpaceWeb.PageLive do
  use SpaceWeb, :live_view
  alias Phoenix.LiveView.Socket
  alias Phoenix.PubSub
  alias SpaceWeb.Presence
  alias UUID
  @pubsub_topic ":space"

  @impl true
  @spec mount(map, map, Socket.t()) :: {:ok, Socket.t(), keyword()}
  def mount(%{"x" => x, "y" => y}, _session, socket) do
    id = UUID.uuid4()
    {x, _} = Integer.parse(x)
    {y, _} = Integer.parse(y)
    PubSub.subscribe(Space.PubSub, topic(socket))

    {:ok,
     assign(
       socket,
       users: get_users(socket),
       name: nil,
       pos: {x, y},
       id: id,
       messages: []
     ), temporary_assigns: [messages: []]}
  end

  def mount(_params, session, socket), do: mount(%{"x" => "0", "y" => "0"}, session, socket)

  @impl true
  def handle_event("change_name", %{"name" => name, "color" => color}, socket) do
    %{id: id, pos: pos} = socket.assigns

    Presence.track(
      self(),
      topic(socket),
      id,
      %{pos: pos, color: color, name: name, id: id}
    )

    socket
    |> assign(name: name, pos: pos, color: color)
    |> noreply()
  end

  def handle_event("move", %{"key" => key}, socket)
      when key in ~w(ArrowDown ArrowLeft ArrowRight ArrowUp) do
    pos = update_pos_by_input(socket.assigns.pos, key)
    # require IEx
    # IEx.pry()

    self()
    |> Presence.update(
      topic(socket),
      socket.assigns.id,
      &Map.put(&1, :pos, pos)
    )

    PubSub.broadcast(Space.PubSub, topic(socket), :moved)

    socket
    |> assign(pos: pos)
    |> noreply()
  end

  def handle_event("move", _, socket), do: {:noreply, socket}

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
    |> Enum.map(fn {_, %{metas: metas}} -> List.first(metas) end)
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
