var AnimatePage = (function() {

	var $pan = $( '#pan-main form' );

	if (!$pan.length) {
		$pan = $('#pan-main');
	}

	var animEndEventNames = {
		'WebkitAnimation' : 'webkitAnimationEnd',
		'OAnimation' : 'oAnimationEnd',
		'msAnimation' : 'MSAnimationEnd',
		'animation' : 'animationend'
	},

	animEndEventName = animEndEventNames[ Modernizr.prefixed( 'animation' ) ],

	support = Modernizr.cssanimations;

	isAnimating = false,
	endCurr 	= false,
	endNext 	= false,
	animcursor 	= 1,
	current 	= 0,

	$pages 		= $pan.children( 'div.pan-page' );



	/* public */
	
	function init() {

		$pages.each( function() {
			var $page = $( this );
			$page.data( 'originalClassList', $page.attr( 'class' ) );
		} );
		
		$pages.eq( current ).addClass( 'pan-page-current' );

	}

	function addAnother( ) {

		var newMsg = ['Keep \'em coming!', 'Need more cards!', 'You\'re killing it! (and by "it" we mean "debt")', 'Give us your cards!', 'Somebody set up us the cards!'];
		var tMsg = Math.floor(Math.random() * newMsg.length);

		var $last_div = $('div[id^="page"]:last');
		var num = parseInt( $last_div.prop('id').match(/\d+/g), 10 ) + 1;

		var $div = $last_div.clone()
		
		// re-id it
		$div.prop('id','page' + num);

		// re-class it.
		$div.prop('class','pan-page pan-page-' + num);

		// attach data for panning
		$div.data( 'originalClassList', $div.attr( 'class' ) );

		// re-id the form fields
		$div.find('input').each( function(index) {

			var tClass = $(this).attr('class'); // the base field name is the class (the actual name already has a number)

			var fieldName = tClass.substring(tClass.indexOf('credit-card'));

			var newFieldId = fieldName + (num-1); // the fields are -1 of the page itself (eg. page-2 has fieldnames named credit-card-label1)

			// re-id it
			$(this).prop('id', newFieldId);

			// and then re-name it
			$(this).prop('name', newFieldId);

		});

		$div.find('.card-content h3').text(newMsg[tMsg]);

		$pan.append( $div );

		return num;
	}

	function panForward( dest ) {

		var o = {
			pageIndex:dest-1,				// convert dest page to dest index
			inAnim:'pan-moveFromRight',						
			outAnim:'pan-moveToLeft'		
		};

		nextPage(o);

	}

	function panBack( dest ) {

		var o = {
			pageIndex:dest-1,				// convert dest page to dest index
			inAnim:'pan-moveFromLeft',
			outAnim:'pan-moveToRight'
		};

		nextPage(o);

	}	

	/* private */

	function nextPage( options ) {

		// pages can be dynamic, so you need to re-get this each time you call nextPage
		$pages = $pan.children( 'div.pan-page' );

		if( isAnimating ) {
			return false;
		}

		isAnimating = true;
		
		// ref. the *true* current page.
		var $currPage = $pages.eq( current );

		// now start working with the dest.
		current = options.pageIndex;

		var $nextPage = $pages.eq( current ).addClass( 'pan-page-current' ), outClass = '', inClass = '';

		inClass = options.inAnim;
		outClass = options.outAnim;

		$currPage.addClass( outClass ).on( animEndEventName, function() {

			$currPage.off( animEndEventName );
			endCurr = true;

			if( endNext ) {
				onEndAnim( $currPage, $nextPage );
			}

		});

		$nextPage.addClass( inClass ).on( animEndEventName, function() {

			$nextPage.off( animEndEventName );
			endNext = true;

			if( endCurr ) {
				onEndAnim( $currPage, $nextPage );
			}

		});

		if( !support ) {
			onEndAnim( $currPage, $nextPage );
		}

	}

	function onEndAnim( $outpage, $inpage ) {
		
		endCurr = false;
		endNext = false;
		
		resetPage( $outpage, $inpage );
		
		isAnimating = false;

	}

	function resetPage( $outpage, $inpage ) {

		$outpage.attr( 'class', $outpage.data( 'originalClassList' ) );
		$inpage.attr( 'class', $inpage.data( 'originalClassList' ) + ' pan-page-current' );

	}

	init();

	return { 
		init : init,
		panForward : panForward,
		panBack : panBack,
		addAnother : addAnother
	};

})();