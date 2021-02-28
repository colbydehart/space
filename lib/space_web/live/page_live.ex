defmodule SpaceWeb.PageLive do
  use SpaceWeb, :live_view
  alias Phoenix.LiveView.Socket
  alias Phoenix.PubSub
  alias SpaceWeb.Presence
  @pubsub_topic ":space"

  @impl true
  @spec mount(map, map, Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    {:ok, assign(socket, grid: [], name: "colby")}
  end

  @impl true
  def handle_event("change_name", %{"name" => name}, socket) do
    Presence.track(self(), topic(socket), name, %{})
    PubSub.subscribe(Space.PubSub, topic(socket))

    socket
    |> assign(name: name)
    |> put_flash(:info, "name changed.")
    |> noreply()
  end

  # Presence events
  @impl true
  def handle_info(%{event: _, payload: _, topic: _}, socket) do
    noreply(socket)
  end

  @spec topic(Socket.t()) :: String.t()
  defp topic(socket), do: socket.host_uri.host <> @pubsub_topic

  defp noreply(term), do: {:noreply, term}
end
