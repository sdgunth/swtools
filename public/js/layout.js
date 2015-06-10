$(document).ready(function() {
	$('ul.dropdown-menu [data-toggle=dropdown]').on('click', function(event) {
	    // Avoid following the href location when clicking
	    event.preventDefault(); 
	    // Avoid having the menu to close when clicking
	    event.stopPropagation(); 
	    // Re-add .open to parent sub-menu item
	    $(this).parent().addClass('open');
	    $(this).parent().find("ul").parent().find("li.dropdown").addClass('open');
	});
});

$(document).ready(function() {
	var bar_height = $(".navbar").height();
	$nav = $($(".navbar").children().get(0)) 
	var moreHeight = (bar_height - $nav.outerHeight())/2;
	var marTopS = $nav.css("margin-top");
	var marTopI = parseInt(marTopS.substring(0, marTopS.length - 2));
	var marBotS = $nav.css("margin-bottom");
	var marBotI = parseInt(marBotS.substring(0, marBotS.length - 2));
	console.log("Changing heights");
	$nav.css("margin-top", marTopI + moreHeight + "px");
	$nav.css("margin-bottom", marBotI + moreHeight + "px");
});