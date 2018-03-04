/* back button capture functionality

1. on pages with panning, log every pan to the _e_history array.

2. trap the back button via window.onbeforeunload

3. during the trap, if the array has length:
- pop the last element off the array.'
- use its value to pan back

4. and of course, if the array has no length, there is no pan history, allow the back button to fire.

o objects will just have the javascript element to fire (say, panBack())
*/

var _e_history = [];
var _e_lasthash = [];
//var _e_current = {};

function addHistory(es, hash) {

  _e_lasthash.push( window.location.hash );
  window.location.hash = hash;

  _e_history.push(es);

}

function goBack() {

  window.location.hash = _e_lasthash[_e_lasthash.length-1];
  _e_lasthash.pop();

  var e = _e_history.pop();
  eval(e);
}

document.onmouseover = function() {
    //User's mouse is inside the page.
    window.innerDocClick = true;
}

document.onmouseleave = function() {
    //User's mouse has left the page.
    window.innerDocClick = false;
}

window.onhashchange = function() {
    if (window.innerDocClick) {
        window.innerDocClick = false;
    } else {
        if (window.location.hash != '#undefined') {
            goBack();
        } else {
            history.pushState("", document.title, window.location.pathname);
            location.reload();
        }
    }
}

$(function(){
    /*
     * this swallows backspace keys on any non-input element.
     * stops backspace -> back
     */
    var rx = /INPUT|SELECT|TEXTAREA/i;

    $(document).bind("keydown keypress", function(e){
        if( e.which == 8 ){ // 8 == backspace
            if(!rx.test(e.target.tagName) || e.target.disabled || e.target.readOnly ){
                e.preventDefault();
            }
        }
    });
});