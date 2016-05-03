module CarouselPanel
	include PageObject
	include SiteSelector

	span   :shop_champs,   :text => 'SHOP CHAMPS'
	span   :shop_mlb,      :text => 'SHOP MLB'
  span   :shop_now,      :text => 'SHOP NOW'

	def click_shop_champs
		shop_champs_element.click
	end

	def click_shop_mlb
		shop_mlb_element.click
  end

  def click_shop_now
    shop_now_element.click
  end

end
