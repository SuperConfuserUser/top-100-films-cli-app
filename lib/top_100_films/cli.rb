class Top100Films::CLI

  def call
    #title_screen
    create_list
    list_films
    menu
    #credits
  end

  def title_screen
    puts <<-DOC
     _____              _  ___   ___      ___ _ _
    /__   \\___  _ __   / |/ _ \\ / _ \\    / __(_) |_ __ ___  ___
      / /\ / _ \\| '_ \\  | | | | | | | |  / _\\ | | | '_ ` _ \\/ __|
     / / | (_) | |_) | | | |_| | |_| | / /   | | | | | | | \\__ \\
     \\/   \\___/| .__/  |_|\\___/ \\___/  \\/    |_|_|_| |_| |_|___/  v #{Top100Films::VERSION}
               |_|

               LIST - full film list      EXIT - exit


                         Press ENTER to start.
    DOC

    input = gets.strip
    abort("Goodbye! ;_;\n") if input.downcase == "exit"
  end

  def create_list
    puts "loading..."
    Top100Films::Scraper.new.scrape_empire
  end

  #list first 10 ond then in increments of 10
  def list_films(start = 0, length = 10)
    puts "--------------------------------------------------------------------------"
    puts "#{list_title(start, length)}:"
    puts "--------------------------------------------------------------------------"

    Top100Films::Film.all[start, length].each do |film|
      puts "#{film.rank}. #{film.title} - #{film.year}"
    end
  end

  def list_title(start, length)
    length == 100 ? "Top 100 Films" : "Films ##{100-start} - ##{100-start-length+1}"
  end

  def menu
    i = 0
    list_increment = 10
    input = nil

    while input != "exit"
      puts "\nENTER for more films, enter <RANK> for film details, LIST for full list, or EXIT:"
      input = gets.strip

      if input.to_i.between?(1, Top100Films::Film.all.length)
        film_details(input.to_i)
      elsif input.strip == ""
        i += 10
        i == Top100Films::Film.all.length - list_increment ? i = 0 : i+= list_increment
        list_films(i)
      elsif input.downcase == "list"
        list_films(0,Top100Films::Film.all.length)
        #should list restart aftershowing full list or continue where it left off?
        i = -list_increment
      elsif input.downcase == "all"
        all_details
      elsif input.downcase == "exit"
        break
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
    puts "--------------------------------------------------------------------------"
    puts "Film \##{rank}: #{film.title}"
    puts "--------------------------------------------------------------------------"
    puts "\nDirector: #{film.director.join(', ')}" if film.director
    puts "Year: #{film.year}"
    puts "Genre: #{film.genre.join(', ')}" if film.genre
    film.synopsis.each {|synopsis| puts "\n#{synopsis}"}
    puts "\nReview: " + "#{film.review_url}".blue
    puts "Trailer: " + "#{film.trailer}".blue if film.trailer
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
