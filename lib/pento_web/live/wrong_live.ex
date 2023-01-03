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
    <h1>Your score: <%= @score %></h1>

    <h2>
      <%= @message %>
    </h2>

    <%= if @answer == :right do %>
      <%= live_patch "Try Again", to: Routes.live_path(@socket, __MODULE__), replace: true %>

    <% else %>

      <h2>
        <%= for n <- 1..10 do %>
          <a href="#" phx-click="guess" phx-value-number={n}><%= n %></a>
        <% end %>
        <pre>
          <%= @current_user.email %>
          <%= @session_id %>
        </pre>
      </h2>

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
