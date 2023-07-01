class VerseGuessesController < ApplicationController
  def create
    @verse = Verse.find_by_id(params[:verse_id])
    @verse_answer = @verse.verse_answers.find_by_id(params[:verse_answer_id])
    score_board = @verse.score_board

    # do something with the points?
    # I think eventually we want to store each answer
    # but for just hacking this together maybe just send 
    # the user and points to the scoreboard.  which also
    # requires a db query each time ugh I guess it can 
    # be backgrounded!!  but not yet
    score_board.add_to_score(
      user_id: current_user.id,
      name: current_user.name,
      points: @verse_answer.point_value
    )
  end
end
