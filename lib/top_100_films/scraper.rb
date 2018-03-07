class Top100Films::Scraper

  def scrape_empire
    doc = Nokogiri::HTML(open("https://www.empireonline.com/movies/features/best-movies/"))

    i=2  #skip first intro paragraph

    doc.css(".article__text h2").each do |film_blurb|
      synopsis = []

      rank, title, year = film_blurb.text.scan(/(^\d*)\.\s(.*)\s\((\d{4})/).flatten

      while doc.css(".article__text p")[i].css("a").text == ""
        synopsis << doc.css(".article__text p")[i].text
        i += 1
      end

      review_url = doc.css(".article__text p")[i].css("a").attribute("href").value

      film = Top100Films::Film.new(rank.to_i, title, year, synopsis, review_url)  

      i += 2  #skip other paragraph objects like photo and title
    end
  end

  def scrape_imdb(film)
    doc = Nokogiri::HTML(open("#{search_imdb(film.title, film.year)}"))

    director = doc.css(".credit_summary_item span[itemprop = 'director'] a").collect {|link| link.text.strip}
    genre = doc.css("div[itemprop = 'genre'] a").collect {|link| link.text.strip}

    if doc.css(".slate").first
      trailer = "http://www.imdb.com" + "#{doc.css("a[itemprop = 'trailer']").attribute("href").value}"
    elsif doc.css(".video_slate").first
      trailer = "http://www.imdb.com" + "#{doc.css(".video_slate a").attribute("href").value}"
    else
      trailer = nil
    end

    film.director = director
    film.trailer = trailer
    film.genre = genre
    film
  end

  def search_imdb(title, year)
    search_url = "http://www.imdb.com/find?q=#{title.gsub(" ", "%20").gsub(":", "%3A").gsub("—", "-").gsub("é", "e").gsub("’", "")}&s=tt&ttype=ft"
    search_doc = Nokogiri::HTML(open("#{search_url}"))
    result_url = "http://www.imdb.com" + search_doc.search(".findList td.result_text").detect{|result| result.text.include?("#{year}")}.css("a").attribute("href").value
  end

end
