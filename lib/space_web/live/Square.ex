defmodule SpaceWeb.Square do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <% {x, y} = @user.pos %>
    <div class="<%= if @is_me, do: "me", else: "" %> person" style="
          grid-column: <%= x %> / <%= x + 1 %>;
          grid-row-start: <%= y %> / <%= y + 1 %>;
    ">
    <div class="namebox"><%= @user.name %></div>
    </div>
    """
  end
end
