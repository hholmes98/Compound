var AnimatePage = (function() {

	var $pan = $( '#pan-main' ),
		
	animEndEventNames = {
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

		$( '.pan-perspective #pay a' ).click( function( e ) {
			e.preventDefault();
			panForward(2);
		});

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
		panBack : panBack
	};

})();