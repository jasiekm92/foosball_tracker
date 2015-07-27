class Player < ActiveRecord::Base
  validates :nickname, presence: true, uniqueness: true, length: { minimum: 2, maximum: 30};
  validates :firstname, :lastname, presence: true, length: { minimum: 2, maximum: 30};
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def full_name
    "#{firstname} #{lastname} (#{nickname})"
  end

  def wins
    Match.where(winner_player_id: self.id) 
  end

  def losts
    Match.where(loser_player_id: id)
  end

  def number_of_wins
    wins.count
  end

  def number_of_losts
    losts.count
  end

  def number_of_matches
    wins.count + losts.count
  end

  def points_earned
    @points = wins.count * 10
    losts.each do |lost|
      @points = @points + lost.loserscore
    end
    @points
  end

  def points_lost
    @points = losts.count * 10
    wins.each do |win|
      @points = @points + win.loserscore
    end
    @points
  end

  def simple_rank_points
    number_of_wins * 1 - number_of_losts * 0.3 + points_earned/10 * 0.1 - points_lost/10 * 0.1 
  end

  def self.simple_rank(players)
    players.to_a.delete_if { |player| player.number_of_matches == 0 }
  end

  def update_rank
    self.rank = simple_rank_points.round(2)
    self.save
  end

  def self.update_position
    @players = Player.all
    @players = @players.sort_by { |player| player.rank.to_i }.reverse

    @players.each_with_index do |player, index|
      player.position = index + 1
      player.save
       end
  end
end
