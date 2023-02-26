class GameSession < ApplicationRecord

  # broadcasts partial: :game_session_badge

  after_create_commit -> {
    Broadcast::GameSession.add_to_index(self)
  }
  after_update_commit -> {
    Broadcast::GameSession.update(self)
  }

  has_many :game_rounds, dependent: :destroy
  has_many :user_game_sessions, dependent: :destroy
  has_many :users, through: :user_game_sessions
  has_many :chat_messages, dependent: :destroy
  has_many :user_answers, dependent: :destroy
  has_many :verses, through: :game_rounds

  validates :name, presence: true

  LOBBY_STATUS = 'LOBBY'
  ACTIVE_STATUS= 'ACTIVE'
  COMPLETED_STATUS = 'COMPLETED'
  STATUSES = [LOBBY_STATUS, ACTIVE_STATUS, COMPLETED_STATUS]

  scope :recent, -> { where("created_at > ?", 120.minutes.ago) }
  scope :lobby, -> { where(status: LOBBY_STATUS) }
  scope :active, -> { where(status: ACTIVE_STATUS) }
  scope :completed, -> { where(status: COMPLETED_STATUS) }
  scope :active_and_lobby, -> { where(status: [LOBBY_STATUS, ACTIVE_STATUS]) }

  def tick!
    if lobby?
      lobby_tick!
    elsif active?
      active_tick!
    elsif completed?
      completed_tick!
    else
      raise "game session has unknown status should not have status #{self.status}"
    end
  end

  def lobby_tick!
    active!
    # GameSessionTickJob.set(wait: 3.seconds).perform_later(self.id)
    GameSessionTickJob.perform_later(self.id)
  end

  def active_tick!
    if current_round
      # GameRoundTickJob.set(wait: 3.seconds).perform_later(current_round.id)
      GameRoundTickJob.perform_later(current_round.id)
    else
      completed!
    end
  end

  def completed_tick!
    # nothing?
  end

  def current_round
    remaining_rounds.first
  end

  def num_rounds
    game_rounds.count
  end

  def num_verses
    game_rounds.sum(&:num_verses)
  end

  def remaining_rounds
    game_rounds.active + game_rounds.queued
  end

  def fill_in_game_info # this is temporary
    3.times do
      game_rounds.create(status: GameRound::QUEUED_STATUS)
    end

    game_rounds.each do |game_round|
      5.times do
        verse = game_round.verses.create
        verse.random_from_fixture
      end
    end
    self
  end

  def lobby?
    self.status == LOBBY_STATUS
  end

  def active?
    self.status == ACTIVE_STATUS
  end

  def completed?
    self.status == COMPLETED_STATUS
  end

  def broadcast_update
    Broadcast::GameSession.update(self)
  end

  private

  def active!
    update_attribute(:status, ACTIVE_STATUS)
  end

  def completed!
    update_attribute(:status, COMPLETED_STATUS)
  end

  def close_game
    update_attribute(:status, COMPLETED_STATUS)
  end

end
