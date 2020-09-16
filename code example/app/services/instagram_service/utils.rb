module InstagramService
  module Utils
    VALID_UUID_RE = /^[a-f\d]{8}\-[a-f\d]{4}\-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}$/

    def raise_if_invalid_rank_token(val, required = true)
      if required && val.blank?
        raise 'rank_token is required'
      elsif !val.match(VALID_UUID_RE)
        raise "Invalid rank_token: #{val}"
      end
      true
    end
  end
end
