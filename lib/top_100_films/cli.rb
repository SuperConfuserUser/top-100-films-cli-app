class Top100Films::CLI

  def call
    #title_screen
    create_list
    list_films(1)
    menu
  #  credits
  end

  def title_screen
    puts <<-DOC
     _____              _  ___   ___      ___ _ _
    /__   \\___  _ __   / |/ _ \\ / _ \\    / __(_) |_ __ ___  ___
      / /\ / _ \\| '_ \\  | | | | | | | |  / _\\ | | | '_ ` _ \\/ __|
     / / | (_) | |_) | | | |_| | |_| | / /   | | | | | | | \\__ \\
     \\/   \\___/| .__/  |_|\\___/ \\___/  \\/    |_|_|_| |_| |_|___/  v #{Top100Films::VERSION}
               |_|

               LIST - main film list      EXIT - exit


                         Press ENTER to start.
    DOC

    input = gets.strip
    abort("Goodbye! ;_;\n") if input.downcase == "exit"
  end

  def create_list
    puts "loading..."
    Top100Films::Scraper.new.scrape_empire
  end

  def list_films(num)
    puts "\n--------------------------------------------------------------------------"
    puts "Top 100 Films:"
    puts "--------------------------------------------------------------------------"

    Top100Films::Film.all.each.with_index(num) do |film,i|
      puts "#{film.rank}. #{film.title} - #{film.year}"
      menu(i) if i%10
    end

  end

  def menu(num)
    input = nil

    while input != "exit"
      puts "\nEnter the RANK of the film for more details, LIST for more films, or EXIT:"
      input = gets.strip

      if input.to_i.between?(1, Top100Films::Film.all.length)
        film_details(input.to_i)
      elsif input.strip == ""
        list_films(num+1)
      elsif input.downcase == "list"
        list_films
      elsif input.downcase == "all"
        all_details
      elsif input.downcase == "exit"
        credits
      else
        puts "Invalid command. Please try again.".red
      end
    end
  end

  def all_details
    Top100Films::Film.all.each {|film| film_details(film.rank)}
  end

  def film_details(rank)
    film = Top100Films::Film.find_by_rank(rank).test_or_create_details
    puts "\n--------------------------------------------------------------------------"
    puts "Film \##{rank}: #{film.title}"
    puts "--------------------------------------------------------------------------"
    puts "\nDirector: #{film.director.join(', ')}" if film.director
    puts "Year: #{film.year}"
    puts "Genre: #{film.genre.join(', ')}" if film.genre
    film.synopsis.each {|synopsis| puts "\n#{synopsis}"}
    puts "\nReview: " + "#{film.review_url}".blue
    puts "Trailer: " + "#{film.trailer}".blue if film.trailer
    puts "\n--------------------------------------------------------------------------"
  end

  def credits
    puts <<-DOC

                                  CREDITS


                            Chely Ho   Developer

                         Patorjk.com   ASCII Art Generator

                             Nokogiri  Gem
                              OpenURI  Gem
                             Colorize  Gem


                  with special thanks to Flatiron School

    DOC
  end

end
