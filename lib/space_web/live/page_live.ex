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
    IO.inspect(socket.host_uri)
    {:ok, assign(socket, grid: [], name: "")}
  end

  @impl true
  def handle_event("change_name", %{"name" => name}, socket) do
    Presence.track(self(), topic(socket), name, %{})

    socket
    |> assign(name: name)
    |> put_flash(:info, "name changed.")
    |> noreply()
  end

  @spec topic(Socket.t()) :: String.t()
  defp topic(socket), do: socket.host_uri.host <> @pubsub_topic

  defp noreply(term), do: {:noreply, term}
end
