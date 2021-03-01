defmodule SpaceWeb.PageLive do
  use SpaceWeb, :live_view
  alias Phoenix.LiveView.Socket
  alias Phoenix.PubSub
  alias SpaceWeb.Presence
  @pubsub_topic ":space"

  @impl true
  @spec mount(map, map, Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    PubSub.subscribe(Space.PubSub, topic(socket))
    Presence.track(self(), topic(socket), "Colby", %{pos: {1, 3}})

    {:ok, assign(socket, users: [], name: nil, pos: nil, messages: []),
     temporary_assigns: [messages: []]}
  end

  @impl true
  def handle_event("change_name", %{"name" => name}, socket) do
    # initial position
    pos = {rand_coord(), rand_coord()}
    Presence.track(self(), topic(socket), name, %{pos: pos})

    socket
    |> assign(name: name, pos: pos)
    |> put_flash(:info, "name changed.")
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

  # Presence events
  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    users =
      socket
      |> topic()
      |> Presence.list()
      |> Enum.map(fn {name, %{metas: metas}} ->
        metas
        |> List.first()
        |> Map.put(:name, name)
      end)

    socket
    |> assign(users: users)
    |> noreply()
  end

  def handle_info({:message, message}, socket) do
    socket
    |> assign(:messages, [message])
    |> noreply()
  end

  # Utility 
  @spec topic(Socket.t()) :: String.t()
  defp topic(socket), do: socket.host_uri.host <> @pubsub_topic

  defp noreply(term), do: {:noreply, term}

  def rand_coord(), do: Enum.random(0..9)
end
