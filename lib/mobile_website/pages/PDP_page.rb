class PdpPage
	include PageObject
	include SiteSelector
	include HeaderPanel
	include FooterPanel

	div  				:prod_details_container,  					:class => 'exp-pdp-container'
	div     		:prod_price_container,  						:class => 'exp-pdp-product-price-container'
	div     		:prod_price,          							:class => 'exp-pdp-product-price'
	span 				:prod_local_price,     							:class => 'exp-pdp-local-price'
	div     		:prod_inventory_messages,           :class => 'exp-pdp-inventory-messages'
	button  		:share_button,                  		:class => 'share-button'
	div  				:prod_buying_tools,   	 						:class => 'buying-tools-container'
	button 			:add_to_cart_button,   							:id => 'add-to-cart-btn'
  div					:product_name,											:class => 'title'

	expected_element  :product_name

	def initialize_page
		has_expected_element?
	end

end