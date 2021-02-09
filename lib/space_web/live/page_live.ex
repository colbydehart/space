defmodule SpaceWeb.PageLive do
  use SpaceWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, grid: [], name: "")}
  end

  @impl true
  def handle_event("change_name", %{"name" => name}, socket) do
    socket
    |> assign(name: name)
    |> flash("name changed.")
    |> noreply()
  end

  defp noreply(term), do: {:noreply, term}
end
