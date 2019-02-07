module TextColor

   COLORS = {
    green: "\u001b[32m",
    red: "\u001b[31m",
    bright_red: "\u001b[31;1m",
    yellow: "\u001b[33m",
    reset: "\u001b[0m"
  }

 def color text
    color =
      case text
      when "M" then :bright_red
      when "!", "Not enough marked fields" then :yellow
      when "x", "X", "Loser" then :red
      when /[0-8]/, "Winner" then :green
      end
    COLORS[color] + text + COLORS[:reset]
  end
end
