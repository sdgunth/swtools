

// Enables the rarity weighting slider
$(document).ready(function() {
	$("#rarity_weight").slider({
		id: "rarity_weight_slider",
		tooltip: "hide",
	    ticks: [0, 1, 2, 3, 4, 5],
	    ticks_labels: ["Ignore", "Minimal", "Mild", "Moderate", "Strong", "Strongest"],
	    ticks_snap_bounds: 0.5
	});
});

//Enables the human preferences slider
$(document).ready(function() {
	$("#human_prefs").slider({
		id: "human_prefs_slider",
		tooltip: "hide",
		ticks: [0, 1, 2],
		ticks_labels: ["No Humans", "Common", "Actual Proportions"],
		ticks_snap_bounds: 0.5,
		value: 2
	});
	$("#human_prefs_slider").attr("style", "margin-bottom: 24px;");
	$("#human_prefs_slider .slider-tick-label").attr("style", "width: 175px;");
	$("#human_prefs_slider .slider-tick-label-container").attr("style", "margin-left: -87.5px;");
});

// Sets all the galactic regions to change the label text
$(document).ready(function() {
	$regions = $("#location_select_button > ul").children();
	$regions.click(function() {
		$("#selected_region").text($(this).contents().text());
	});
});

// Enables the generate button
$(document).ready(function() {
	$("#generate_button").click(function() {
		var generated = generateSpecies();
	});
});

function generateSpecies() {
	var get_url = "/api/generators/species-select";
	var gen_data = {
		"rarity_prefs": $("#rarity_weight").slider('getValue'),
		"human_prefs": $("#human_prefs").slider('getValue')
	};
	$.ajax({
		url: get_url,
		method: "GET",
		data: gen_data,
		dataType: "json",
	}).done(function(data) {
		$("#generate_button").before($('<div class="panel panel-primary"><div class="panel-heading">Results</div><div class="panel-body"><a href="http://starwars.wikia.com/' + data + '">' + data + '</a></div></div>'));
	});
}