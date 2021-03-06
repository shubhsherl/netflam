# METER                                  An implementation of meter classifier.
#
# Version:                                helpers/meter.rb    0.0.1    04/10/14
# Authors:              Maciej A. Czyzewski, <maciejanthonyczyzewski@gmail.com>

class Netflam
  module Meter
    # Story points & user karma
    @votes = :votes
    @users = :users

    # Dynamic stream
    @score = :score

    class << self
      def save(story_id)
        story = Story.find(story_id)

        user_id    = story.user_id
        created_at = story.created_at

        score = Netflam::Meter.score(story_id)
        karma = Netflam::Meter.karma(user_id)

        $redis.zadd(@votes.to_s, score + 1, story_id)
        $redis.zadd(@users.to_s, karma + 1, user_id)

        $redis.zadd(@score.to_s, created_at.to_i / (12 * 60 * 60) + Math.log10(score + 1), story_id)
      end

      def destroy(story_id)
        user_id = Story.find(story_id).user_id

        score = Netflam::Meter.score(story_id)
        karma = Netflam::Meter.karma(user_id)

        if score > 1
          $redis.zadd(@votes.to_s, score - 1, story_id)
        else
          $redis.zrem(@votes.to_s, story_id)
        end

        $redis.zadd(@users.to_s, karma - 1, user_id)
      end

      def score(story_id)
        $redis.zscore(@votes.to_s, story_id).to_i
      end

      def karma(user_id)
        $redis.zscore(@users.to_s, user_id).to_i
      end

      def top(a, b)
        $redis.zrevrange(@score.to_s, a, b)
      end

      def type(story_id)
        inta = $redis.zcard(@votes.to_s)
        rank = $redis.zrank(@votes.to_s, story_id)
        bttm = inta / 6

        # Types: a b c d e f
        if rank != nil and inta != nil
          if rank.between?(0, bttm * 0.1)
            return "f"
          elsif rank.between?(bttm * 0.1, bttm * 0.3)
            return "e"
          elsif rank.between?(bttm * 0.3, bttm * 0.5)
            return "d"
          elsif rank.between?(bttm * 0.5, bttm * 1)
            return "c"
          elsif rank.between?(bttm * 1, bttm * 3)
            return "b"
          elsif rank.between?(bttm * 3, inta)
            return "a"
          end
        else
          return "a"
        end
      end
    end
  end
end