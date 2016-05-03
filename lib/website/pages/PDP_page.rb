class PdpPage
	include PageObject
	include SiteSelector
	include HeaderPanel
	include FooterPanel

	div     :prod_details_content,     :class => 'exp-pdp-main-pdp-content'
	div  :prod_details_container,  :class => 'exp-pdp-content-container '
	div     :prod_image_details_container,  :class => 'exp-pdp-hero-and-alt-images-container'
	div     :prod_image_container,          :class => 'exp-pdp-product-image'
	image :prod_image,     :class => 'exp-pdp-small-hero-image'
	div     :prod_all_iamges,               :class => 'exp-pdp-alt-images-container'
	button  :share_button,                  :class => 'exp-share-button'
	div     :prod_header,                  :class => 'exp-product-header'
	div     :prod_info,                  :class => 'hero-product-style-color-info'
	span :prod_price,     :class => 'exp-pdp-local-price'
	div     :prod_colors,     :class => 'exp-pdp-colorways'
	div  :prod_buying_tools,    :id => 'exp-pdp-buying-tools-container'
	button :add_to_cart_button,   :id => 'buyingtools-add-to-cart-button'
	div  :chat_module_section,   :id => 'chatModule'
	div  :promo_wrapper_section,   :class => 'exp-pdp-promo-wrapper'
	div  :certeno_crosssell_section,  :class =>'certona-crossSell'
	div  :prod_benefits_section,   :class => 'exp-pdp-benefits-container'
	div  :prod_reviews_section,   :id => 'exp-reviews-section'
	h1    :product,                   :class =>'exp-product-title'

	expected_element  :prod_header

	def initialize_page
		has_expected_element?
	end

end