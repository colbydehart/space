defmodule SpaceWeb.Square do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <% {x, y} = @user.pos %>
    <span 
      title="<%= @user.name %>" 
      style="grid-column-start: <%= x + 1 %>;
             grid-column-end: span 1;
             grid-row-start: <%= y + 1 %>;
             grid-row-end: span 1;">
      <div 
        class="<%= if @is_me, do: "me", else: "" %> person"
        style="background-color: <%= @user.color %>;"></div>
    </span>
    """
  end
end
