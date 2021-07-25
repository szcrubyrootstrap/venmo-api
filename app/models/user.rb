# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  amount     :float            default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_many :friendships, foreign_key: :user_a_id, inverse_of: :user_a, dependent: :destroy
  has_many :friends, through: :friendships, class_name: 'User', source: :user_b
  has_many :payments, foreign_key: :sender_id, inverse_of: :sender, dependent: :nullify
  has_many :incoming_payments, foreign_key: :receiver_id, class_name: 'Payment',
                               inverse_of: :receiver, dependent: :nullify

  def add_friend(user)
    friendships.create!(user_b: user)
    user.friendships.create!(user_b: self)
  end

  def my_friend?(friend)
    friends.find_by(id: friend.id).present?
  end

  def add_funds(value)
    raise Api::NonePositiveAmountError if value <= 0

    self.amount += value
    save!
  end

  alias add_to_balance add_funds

  def subtract_funds(value)
    raise Api::NonePositiveAmountError if value <= 0

    self.amount -= value
    save!
    value
  end

  def funds_required(value)
    amount - value
  end

  def can_send?(value)
    funds_required(value) >= 0
  end
end
