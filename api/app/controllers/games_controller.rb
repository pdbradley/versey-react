class GamesController < ApplicationController

  def create
    game_session = GameSession.create(creator_uuid: params[:creator_uuid], name: params[:name], status: GameSession::LOBBY_STATUS)

    if game_session.persisted?
      # background this?
      num_verses = params[:num_verses]
      num_rounds = params[:num_rounds]
      BuildsGameSessionStructure.new(game_session.id).build(num_rounds: num_rounds, num_verses: num_verses*num_rounds)
      game_session.reload
      render json: game_session
    else
      render error: { error: 'Unable to create game session' }
    end
  end

  def start
    game_session = GameSession.find_by(uuid: params[:uuid])

    if game_session
      game_session.tick!
      render :success
    else
      render error: { error: 'Unable to start game session' }
    end
  end
end
