class CardController < ApplicationController

  require "payjp"
  before_action :set_card

  def new
    redirect_to action: "show" if @card.exists?
  end

  def pay #payjpとCardのデータベース作成を実施します。
    Payjp.api_key = "sk_test_f7fbcf1683090edbdfed5d6d"
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      customer = Payjp::Customer.create(
      description: '登録テスト', #なくてもOK
      email: current_user.email, #なくてもOK
      card: params['payjp-token'],
      metadata: {user_id: current_user.id}
      ) #念の為metadataにuser_idを入れましたがなくてもOK
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        redirect_to action: "show"
      else
        redirect_to action: "pay"
      end
    end
  end

  def delete #PayjpとCardデータベースを削除します
    if @card.present?
      Payjp.api_key = "sk_test_f7fbcf1683090edbdfed5d6d"
      customer = Payjp::Customer.retrieve(card.customer_id)
      customer.delete
      @card.delete
    end
      redirect_to action: "new"
  end

  def show #Cardのデータpayjpに送り情報を取り出します
    if @card.blank?
      redirect_to action: "new" 
    else
      Payjp.api_key = "sk_test_f7fbcf1683090edbdfed5d6d"
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
  end
end

private

def set_card
  @card = Card.where(user_id: current_user.id)
end