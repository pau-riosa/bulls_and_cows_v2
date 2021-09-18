# Bulls and Cows

## Rules

The numerical version of the game is usually played with 4 digits, but can also be played with 3 or any other number of digits.

On a sheet of paper, the players each write a 4-digit secret number. The digits must be all different. Then, in turn, the players try to guess their opponent's number who gives the number of matches. If the matching digits are in their right positions, they are "bulls", if in different positions, they are "cows". Example:

Secret number: 4271 Opponent's try: 1234 Answer: 1 bull and 2 cows. (The bull is "2", the cows are "4" and "1".) The first player to reveal the other's secret number in the fewest guesses wins the game.

## Tools

- Phoenix LiveView
- Elixir 1.12
- Erlang OTP 24

## To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
