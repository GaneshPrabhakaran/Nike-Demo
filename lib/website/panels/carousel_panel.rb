module CarouselPanel
	include PageObject
	include SiteSelector

	div			:cq_content,				:class => 'nike-cq-content'
	div			:cq_container,				:class => 'nike-cq-container'
	div			:cq_section,				:class => 'nike-cq-nike-com-section'
	div			:fst_image,					:class => 'nike-cq-nike-com-section-fst-image-carousel'

	div			:fst_image_container,		:class => 'nike-cq-page-section-fst-image-carousel-container'
	div			:anchor_link_wrapper,		:class => 'nike-cq-container-module-anchor-link-wrapper'
	div			:fst_image_content_wrapper,	:class => 'nike-cq-fst-image-carousel-content-wrapper'
	div			:fst_image_reference,		:class => 'nike-cq-fst-image-carousel-reference'
	div			:base,						:class => 'nike-cq-carousel-base'
	div			:full_screen,				:class => 'nike-cq-carousel-full-screen'
	div			:slide_collection,			:class => 'nike-cq-carousel-slide-collection'
	div			:slick_track,				:class => 'slick-track'
	divs		:slick_slide,				:class => 'slick-slide'
	div			:dots,						:class => 'nike-cq-carousel-dots'
	div			:prev_button,				:class => 'nsg-button--carousel-arrow--prev'
	div			:next_button,				:class => 'nsg-button--carousel-arrow--next'
	divs    :sub_titles,      :class => 'nike-cq-block-subtitles'

	def get_sub_titles
		title= []
		sub_titles_elements.each { |e| title << e.span_element(:class => 'nike-cq-title-line-1').text  }
		title
	end

	def prev_button
		prev_button_element.click
	end

end
