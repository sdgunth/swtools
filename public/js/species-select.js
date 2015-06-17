var social_statuses = ['Liked', 'Respected', 'Beloved', 'Enslaved', 'Denigrated', 'Feared', 'Hated', 'Neutral', 'Mysterious'];

// Enables the sliders (#rarity_weight and #human_prefs)
$(document).ready(function() {
	// Rarity weight slider
	$("#rarity_weight").slider({
		id: "rarity_weight_slider",
		tooltip: "hide",
	    ticks: [0, 1, 2, 3, 4, 5],
	    ticks_labels: ["Ignore", "Minimal", "Mild", "Moderate", "Strong", "Strongest"],
	    ticks_snap_bounds: 0.5
	});
	
	// Human prefs slider
	$("#human_prefs").slider({
		id: "human_prefs_slider",
		tooltip: "hide",
		ticks: [0, 1, 2],
		ticks_labels: ["No Humans", "Common", "Actual Proportions"],
		ticks_snap_bounds: 0.5,
		value: 2
	});
	// Makes it so the slider actually displays properly in hidden tabs
	$("#human_prefs_slider").attr("style", "margin-bottom: 24px;");
	$("#human_prefs_slider .slider-tick-label").attr("style", "width: 175px;");
	$("#human_prefs_slider .slider-tick-label-container").attr("style", "margin-left: -87.5px;");
});

// Makes the dropdown buttons work (#location_select_button and #num_results_button)
$(document).ready(function() {
	// Location Select button
	$regions = $("#location_select_button > ul").children();
	$regions.click(function() {
		$("#selected_region").text($(this).contents().text());
	});
	
	// Num Results button
	$regions = $("#num_results_button > ul").children();
	$regions.click(function() {
		$("#number_of_results").text($(this).contents().text());
	});
});

// Enables the switches
$(document).ready(function() {
	for (var i = 0; i < social_statuses.length; i++) {
		var temp = social_statuses[i].toLowerCase();
		$("#" + temp + "_forced_radio").bootstrapSwitch();
		$("#" + temp + "_disabled_radio").bootstrapSwitch();
	}
//	var $liked_forced_checkbox = $("#liked_forced_checkbox").bootstrapSwitch();
//	var $liked_disabled_checkbox = $("#liked_disabled_checkbox").bootstrapSwitch();
//	$("#liked_forced_checkbox").click(function() {
//		if $("#liked_disabled_checkbox").
//	});
});

// Enables the generate button
$(document).ready(function() {
	$("#generate_button").click(function() {
		var generated = generateSpecies(Number($("#number_of_results").text()));
	});
});

function socialStatus() {
	// True if the trait in the key-value pair has no deciding factors, false otherwise
	var is_choice = [];
	// True if the trait is required, false if it is disallowed
	var restriction = [];
	for (var i = 0; i < social_statuses.length; i++) {
		var temp = social_statuses[i].toLowerCase();
		if ($("#" + temp + "_forced_radio").bootstrapSwitch('state')) {
			is_choice[i] = false;
			restriction[i] = true;
		} else if ($("#" + temp + "_disabled_radio").bootstrapSwitch('state')) {
			is_choice[i] = false;
			restriction[i] = false;
		} else {
			is_choice[i] = true;
			restriction[i] = false;
		}
	}
	var results = [is_choice, restriction];
	return results;
}

function generateSpecies(num) {
	var selections = [];
	var get_url = "/api/generators/species-select";
	var galactic_region;
	if ($("#selected_region").text() == "(Select)") {
		galactic_region = "Core Worlds";
	} else {
		galactic_region = $("#selected_region").text();
	}
	var gen_data = {
		"rarity_prefs": $("#rarity_weight").slider('getValue'),
		"human_prefs": $("#human_prefs").slider('getValue'),
		"galactic_location": galactic_region,
		"num_species": num,
		"social_statuses": socialStatus()
	};
	$.ajax({
		url: get_url,
		method: "GET",
		data: gen_data,
		dataType: "json",
	}).done(function(data) {
		console.log(data);
		console.log(data.length);
		for (i = 0; i < num; i++) {
			selections.push($('<p><a href="' + data[i][1] + '" target="_blank">' + data[i][0] + '</a></p>'));
		}
		if ($("#results_panel").length == 0) {
			$("#num_results_button").before($('<div id="results_panel" class="panel panel-primary"><div class="panel-heading">Results</div><div class="panel-body"></div></div>'));
		} else {
			$("#results_panel > .panel-body").empty();
		}
		for (i = 0; i < num; i++) {
			$("#results_panel > .panel-body").append(selections[i]);
		}
	});
}