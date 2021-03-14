defmodule SpaceWeb.Square do
  use Phoenix.LiveComponent

  def render(assigns) do
    assigns.users
    |> Enum.find(&(&1.pos == assigns.pos))
    |> case do
      nil ->
        ~L"<div class=\"cell\"></div>"

      user ->
        assigns = Map.put(assigns, :user, user)

        ~L"""
        <div class="cell" style="background-color: <%= @user.color %>;">
          <div class="tooltip"><%= @user.name %></div>
        </div>
        """
    end
  end
end
