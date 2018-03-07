class Top100Films::Film

  attr_accessor :rank, :title, :year, :synopsis, :review_url, :director, :genre, :trailer

  @@all = []

  def self.all
    @@all
  end

  def initialize(rank, title, year, synopsis, review_url)
    @rank = rank
    @title = title
    @year = year
    @synopsis = synopsis
    @review_url = review_url
    @@all << self
  end

  def self.find_by_rank(rank)
    @@all.detect{|film| film.rank == rank}
  end

  def test_or_create_details
    @trailer ? self : Top100Films::Scraper.new.scrape_imdb(self)
  end

end
