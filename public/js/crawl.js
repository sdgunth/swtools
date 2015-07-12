/* Original code belongs to Tim Pietrusky, but I've basically replaced it all
 * 
 * Sound copyright the Walt Disney Company
 */

// Sets up the appropriate audio to play
var warsTheme;

$(document).ready(function() {
	var audio = new Audio();
	if (audio.canPlayType("audio/mpeg") != "") {
		warsTheme = $("audio")[0];
	} else if (audio.canPlayType("audio/ogg") != ""){
		warsTheme = $("audio")[1];
	} else {
		warsTheme = null;
	}
	if (warsTheme) {
		warsTheme.pause();
	}
	console.log("Setup");
});

//Toggles the play/pause state of the theme
function toggleTheme() {
	if (warsTheme) {
		if (warsTheme.paused) {
			warsTheme.play();
		} else {
			warsTheme.pause();
		}
	} 		
}

function toggleAnimation() {
	if ($(".paused").length > 0) {
		$(".paused").removeClass("paused");
	} else {
		$(".intro .titles .logo").addClass("paused");
	}
}

function startCrawl() {
	$(".start").fadeOut();
	toggleTheme();
	toggleAnimation();
}

// Sets clicking the start button to start the crawl
$(document).ready(function() {
	$(".start").click(function() {
		startCrawl();
	});
});