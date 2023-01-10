defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, session, socket) do
    {:ok,
     assign(
       socket,
       score: 0,
       random_number: Enum.random(1..10),
       message: "Make a guess:",
       answer: nil,
       session_id: session["live_socket_id"]
     )}
  end

  def render(assigns) do
    ~H"""
    <style>
      h1 {
        color: blue;
      }

      a {
        display: inline-block;
        padding: 0.5rem 1rem;
        margin: 0.5rem;
        text-decoration: none;
        background-color: gray;
        color: white;
      }

      a:hover {
        background-color: darkgray;
      }

      .score {
        text-align: center;
      }

      .username {
        color: green;
      }

      .session_id {
        color: red;
      }
    </style>

    <div class="score">
      <h1>Your score: <%= @score %></h1>

      <h2>
        <%= @message %>
      </h2>
    </div>

    <%= if @answer == :right do %>
      <%= live_patch "Try Again", to: Routes.live_path(@socket, __MODULE__), replace: true %>

    <% else %>

      <h2>
        <%= for n <- 1..10 do %>
          <a href="#" phx-click="guess" phx-value-number={n}><%= n %></a>
        <% end %>
      </h2>
      <div class="username">
        <%= @current_user.username %>
      </div>
      <div class="session_id">
        <%= @session_id %>
      </div>

    <% end %>
    """
  end

  def handle_event("guess", %{"number" => guess} = _data, socket) do
    {score, message, answer} =
      case calc_guess(String.to_integer(guess), socket.assigns) do
        {:right, score} -> {score, "Your guess: #{guess} is right. Congratulation.", :right}
        {:wrong, score} -> {score, "Your guess: #{guess}. is wrong. Guess again.", :wrong}
      end

    {:noreply, assign(socket, message: message, score: score, answer: answer)}
  end

  def handle_params(%{}, _, socket) do
    {:noreply,
     assign(socket, random_number: Enum.random(1..10), answer: nil, message: "Make a guess:")}
  end

  defp calc_guess(guess, %{score: score, random_number: random_number})
       when guess == random_number,
       do: {:right, score + 1}

  defp calc_guess(_guess, %{score: score}), do: {:wrong, score - 1}
end
