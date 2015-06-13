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

// Sets all the galactic regions to change the label text
$(document).ready(function() {
	$regions = $("#location_select_button > ul").children();
	$regions.click(function() {
		$("#selected_region").text($(this).contents().text());
	});
});