defmodule SpaceWeb.LayoutView do
  use SpaceWeb, :view

  def color_for_square(pos, users) do
    case Enum.find(users, &(&1.pos === pos)) do
      nil -> ""
      user -> user.color
    end
  end
end
