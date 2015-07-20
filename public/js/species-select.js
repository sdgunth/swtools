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
		id = $(this).attr('id');
		$siblings = $("[class*='bootstrap-switch-id-" + id + "'] ~ div > button");
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
	var sym_social_statuses = ["liked", "respected", "beloved", "enslaved", "denigrated", "feared", "hated", "neutral", "mysterious"];

	// If there aren't any restrictions, save time
	if (is_choice.indexOf(false) == -1) {
		return null;
	}
	var required = [];
	var forbidden = [];
	// Parse down to the ones to be used, return only those
	while (is_choice.indexOf(false) > -1) {
		var ind = is_choice.indexOf(false);
		if (restriction[ind]) {
			required.push(sym_social_statuses[ind]);
		} else {
			forbidden.push(sym_social_statuses[ind]);
		}
		sym_social_statuses.splice(ind, 1);
		is_choice.splice(ind, 1);
		restriction.splice(ind, 1)
	}
	
	var results = [required, forbidden];
	return results;
}

function bioType() {
	var $buttons = $("#biology_type_checkboxes").children();
	var prefs = [];
	$buttons.each(function(index, value) {
		prefs.push($(value).val());
	});
	return prefs;
}

function bodilyStructure() {
	var $buttons = $("#bodily_structure_checkboxes").children();
	var prefs = [];
	$buttons.each(function(index, value) {
		prefs.push($(value).val());
	});
	return prefs;	
}

function size() {
	var prefs = [];
	prefs.push($("#size_matters_checkbox").bootstrapSwitch('state'));
	var comp_text = $("#size_comparison_button > button > span:first-child").text();
	if (comp_text != "(Select)") {
		prefs.push(comp_text);
	} else {
		prefs[0] = false;
		prefs.push("=");
	}
	var size_text = $("#sizes_button > button > span:first-child").text();
	if (size_text != "(Select)") {
		prefs.push(size_text);
	} else {
		prefs[0] = false;
		prefs.push("Average");
	}
	return prefs;
}

function diet() {
	var $buttons = $("#diet_checkboxes").children();
	var prefs = [];
	$buttons.each(function(index, value) {
		prefs.push($(value).val());
	});
	return prefs;	
}

function genders() {
	var $buttons = $("#genders_checkboxes").children();
	var prefs = [];
	$buttons.each(function(index, value) {
		prefs.push($(value).val());
	});
	return prefs;	
}

function forceSensitivity() {
	var $buttons = $("#force_sensitivity_checkboxes").children();
	var checkboxes = [];
	$buttons.each(function(index, value) {
		checkboxes.push($(value).val());
	});
	var is_bias = true;
	if ($("#selected_force_sensitivity_bias").text() == "(Select)" || $("#selected_force_sensitivity_bias").text() == "No Bias") {
		is_bias = false;
	}
	var prefs = {"frequencies" : checkboxes,
				"bias_presence" : is_bias,
				"bias" : $("#force_sensitivity_bias").text()};
	return prefs;	
}

function lifespan() {
	var prefs = {
		"lifespan_matters": $("#lifespan_matters_checkbox").bootstrapSwitch('state'),
		"lifespan_comparator": $("#selected_lifespan_comparator").text(),
		"lifespan_text": $("#selected_lifespan").text()
	};
	return prefs;
}

function gender() {
	var prefs = {
		"gender_ratio_matters": $("#gender_ratio_matters_checkbox").bootstrapSwitch('state'),
		"gender_ratio_comparator": $("#selected_gender_ratio_comparator").text(),
		"gender_ratio_text": $("#selected_gender_ratio").text()
	};
	return prefs;
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
		"social_statuses": socialStatus(),
		"bio_type": bioType(),
		"body_structure": bodilyStructure(),
		"size": size(),
		"diet": diet(),
		"force_sensitivity": forceSensitivity(),
		"lifespan": lifespan()
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