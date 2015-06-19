var social_statuses = ['Liked', 'Respected', 'Beloved', 'Enslaved', 'Denigrated', 'Feared', 'Hated', 'Neutral', 'Mysterious'];

var already_heightfixed = [];

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

// Makes the dropdown buttons work
$(document).ready(function() {
	$buttons = $("div.btn-group > ul.dropdown-menu");
	$buttons.each(function(index, value) {
		$list = $(value).children();
		$list.click(function() {
			$(value).parent().find("span:first").text($(this).contents().text());	
		});
	});
});

// Enables the switches
$(document).ready(function() {
	$switches = $(".bs-switch");
	$switches.each(function(value, index) {
		$(index).bootstrapSwitch()
	});
	
	// Handles the ___ Matters switches
	$("[id$='_matters_checkbox']").on('switchChange.bootstrapSwitch', function(event, state) {
		console.log('Switch changed');
		$siblings = $("[class*='bootstrap-switch-id-'][class*='_matters_checkbox'] ~ div > button");
		$siblings.each(function(key, value) {
			if (state) {
				$(value).prop("disabled", false);
			} else {
				$(value).prop("disabled", true);
			}
		});
	});
});

// Enables the checkbox buttons
$(document).ready(function() {
	$(".btn-group.btn-checkbox-group > .btn.btn-default").click(function() {
		var $this = $(this);
		if ($this.val() == "true") {
			$this.val("false");
		} else {
			$this.val("true");
		}
	});
});

// Enables the generate button
$(document).ready(function() {
	$("#generate_button").click(function() {
		var generated = generateSpecies(Number($("#number_of_results").text()));
	});
});


//Enables things that need to fire when a tab is shown
$(document).ready(function() {
	$('a[data-toggle="tab"]').on('shown.bs.tab', function(tab) {
		var $opened_tab = $(tab.target).attr("href");
		panelHeightfix($opened_tab);
	});
});

// Heightfix for tabs
function panelHeightfix(parent_element) {
	var $heightfix = $(parent_element).find(".panel-heightfix:visible");
	$heightfix.each(function(index, value) {
		console.log($(value).children('.panel-body').outerHeight(false));
		if ($.inArray(value, already_heightfixed) == -1) {
			// Add 30px to account for vertical padding of body
			var body_height = $(value).children(".panel-body").outerHeight(false);
			console.log("Setting height to " + body_height);
			console.log($(value));
			$(value).height(body_height);
			already_heightfixed.push(value);
			// Fix for bootstrap switches not immediately having the correct size
			if ($(value).find(".bootstrap-switch").length > 0) {
				setTimeout(function() {
					body_height = $(value).children(".panel-body").outerHeight(false)
					$(value).height(body_height);
				}, 100);
			}
		}
	});
}

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