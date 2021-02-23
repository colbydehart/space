defmodule SpaceWeb.Presence do
  use Phoenix.Presence,
    otp_app: :space,
    pubsub_server: Space.PubSub
end
