# frozen_string_literal: true

module Lockable
  extend ActiveSupport::Concern

  LOCK_KEYS = {
    "Offer" => 1
  }.freeze

  def with_advisory_lock
    transaction do
      self.class.connection.execute advisory_lock_sql

      yield
    end
  end

  private
    def advisory_lock_sql
      "select #{self.class.sanitize_sql(["pg_advisory_xact_lock(?, ?)", LOCK_KEYS.fetch(self.class.name), id])}"
    end
end
