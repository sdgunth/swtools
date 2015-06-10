var usedSkills = []
var allSkills;

// access with skillMap[column, row], indexing starts from top-left
var skillMap;
var arrangement;
var skillPoints;
var pointsRemaining;

var skillCols = 7;
var skillRows = 5;

var refresh;
var minStunts;
var maxStunts;

var currentStunts = 0;
var currentExtras = 0;

var extraCosts = [];

// URL in the image url entry replaces extant image
$(document).ready(function() {
	$("#img_url").keyup(function(event) {
		if (event.which == 13) {
			$("#char_pic").attr("src", $("#img_url").val());
			$("#img_url").blur();
		}
	});
});

$("ul.nav-tabs a").click(function (e) {
	  e.preventDefault();  
	    $(this).tab('show');
	});


// Autosizes textareas to content
$(document).ready(function(){
    $('textarea').autosize();    
});

// Initialization Stuff
$(document).ready(function() {
	initSetup();
	initializeSkillMap();
	newSkillSelection();
});

function initSetup() {
	allSkills = JSON.parse($("#skill_list").val());
	arrangement = $("#skill_arrangement").val();
	skillPoints = $("#skill_points").val();
	refresh = $("#refresh").val();
	minStunts = $("#min_stunts").val();
	maxStunts = $("#max_stunts").val();
	pointsRemaining = skillPoints;
}

// Stunts and Extras

$(document).ready(function() {
	$("#add_stunt").click(function() {
		if (currentStunts < maxStunts) {
			
			var nStuntHead = document.createElement("li");
			$nStuntHead = $(nStuntHead);
			
			var nStuntHeadA = document.createElement("a");
			$nStuntHeadA = $(nStuntHeadA);
			$nStuntHeadA.attr("data-toggle", "tab");
			$nStuntHeadA.attr("class", "layered-tab");
			$nStuntHeadA.attr("id", "stunt_" + currentStunts + "_a");
			$nStuntHeadA.html("New Stunt " + (currentStunts +1));
			$nStuntHeadA.attr("href", "#stunt_" + currentStunts);
			$nStuntHead.append($nStuntHeadA);
			
			$("#stunt-add-li").parent().prepend($nStuntHead);
			
			var pane = document.createElement("div");
			$pane = $(pane);
			if (currentStunts > 0) {
				$pane.addClass("tab-pane fade");
			} else {
				$pane.addClass("tab-pane fade active in");
			}
			$pane.attr("id", "stunt_" + currentStunts);
			
			var row = document.createElement("div");
			$row = $(row);
			$row.attr("class", "row");
			
			var leftCol = document.createElement("div");
			$leftCol = $(leftCol);
			$leftCol.attr("class", "col-lg-6");
			
			var rightCol = document.createElement("div");
			$rightCol = $(rightCol);
			$rightCol.attr("class", "col-lg-6");
			
			var fullCol = document.createElement("div");
			$fullCol = $(fullCol);
			$fullCol.attr("class", "col-lg-12");
			
			var nameIG = document.createElement("div");
			$nameIG = $(nameIG);
			$nameIG.attr("class", "input-group ig-spaced");
			
			var nameIGAddon = document.createElement("span");
			$nameIGAddon = $(nameIGAddon);
			$nameIGAddon.attr("class", "input-group-addon");
			$nameIGAddon.html("Name");
			
			var nameIGField = document.createElement("input");
			$nameIGField = $(nameIGField);
			$nameIGField.attr("class", "form-control");
			$nameIGField.attr("type", "text");
			$nameIGField.attr("name", "stunt_" + currentStunts + "_name");
			$nameIGField.attr("currStunt", currentStunts);
			
			// Makes changing the name field change the name of the tab
			$nameIGField.focusout(function () {
				var t = "#stunt_" + $(this).attr("currStunt") + "_a";
				newName = $(this).val();
				if ($(t).test(/\S/) == true) {
					$(t).html(newName);
				} else {
					var n = "Stunt " + (parseInt($(this).attr("currStunt"))+1)
					$(t).html(n);
				}
			});
			
			var sourceIG = document.createElement("div");
			$sourceIG = $(sourceIG);
			$sourceIG.attr("class", "input-group ig-spaced");
			
			var sourceIGAddon = document.createElement("span");
			$sourceIGAddon = $(sourceIGAddon);
			$sourceIGAddon.attr("class", "input-group-addon");
			$sourceIGAddon.html("Source");
			
			var sourceIGField = document.createElement("input");
			$sourceIGField = $(sourceIGField);
			$sourceIGField.attr("class", "form-control");
			$sourceIGField.attr("type", "text");
			$sourceIGField.attr("name", "stunt_" + currentStunts + "_source");
			
			var descIG = document.createElement("div");
			$descIG = $(descIG);
			$descIG.attr("class", "input-group ig-spaced");
			
			var descIGAddon = document.createElement("span");
			$descIGAddon = $(descIGAddon);
			$descIGAddon.attr("class", "input-group-addon");
			$descIGAddon.html("Description");
			
			var descIGField = document.createElement("textarea");
			$descIGField = $(descIGField);
			$descIGField.attr("class", "form-control");
			$descIGField.attr("rows", "3");
			$descIGField.attr("name", "extra_" + currentStunts + "_description");
						
			$("#stunts-tab-content").prepend($pane);
	
			$pane.append($row);
			$row.append($leftCol);
			$row.append($rightCol);
		
			$leftCol.append($nameIG);
			$nameIG.append($nameIGAddon);
			$nameIG.append($nameIGField);
			
			$rightCol.append($sourceIG);
			$sourceIG.append($sourceIGAddon);
			$sourceIG.append($sourceIGField);
			
			$row.append($fullCol);
			$fullCol.append($descIG);
			$descIG.append($descIGAddon);
			$descIG.append($descIGField);
					
			currentStunts++;
			updateCosts();
		} else if (parseInt($("#refresh_remaining_a").html()) == 1) {
			alert("You don't have enough refresh to add another stunt");
		} else {
			alert("You have made all the stunts you are allowed to!");
		}
	});
});

$(document).ready(function() {
	$("#add_extra").click(function() {
		var nExtraHead = document.createElement("li");
		$nExtraHead = $(nExtraHead);
		
		var nExtraHeadA = document.createElement("a");
		$nExtraHeadA = $(nExtraHeadA);
		$nExtraHeadA.attr("data-toggle", "tab");
		$nExtraHeadA.attr("class", "layered-tab");
		$nExtraHeadA.attr("id", "extra_" + currentExtras + "_a");
		$nExtraHeadA.html("New Extra " + (currentExtras +1));
		$nExtraHeadA.attr("href", "#extra_" + currentExtras);
		$nExtraHead.append($nExtraHeadA);
		
		$("#extra-add-li").parent().prepend($nExtraHead);
		
		var pane = document.createElement("div");
		$pane = $(pane);
		if (currentExtras > 0) {
			$pane.addClass("tab-pane fade");
		} else {
			$pane.addClass("tab-pane fade active in");
		}
		$pane.attr("id", "extra_" + currentExtras);
		
		var row = document.createElement("div");
		$row = $(row);
		$row.attr("class", "row");
		
		var leftCol = document.createElement("div");
		$leftCol = $(leftCol);
		$leftCol.attr("class", "col-lg-5");
		
		var midCol = document.createElement("div");
		$midCol = $(midCol);
		$midCol.attr("class", "col-lg-2");
		
		var rightCol = document.createElement("div");
		$rightCol = $(rightCol);
		$rightCol.attr("class", "col-lg-5");
		
		var fullCol = document.createElement("div");
		$fullCol = $(fullCol);
		$fullCol.attr("class", "col-lg-12");
		
		var nameIG = document.createElement("div");
		$nameIG = $(nameIG);
		$nameIG.attr("class", "input-group ig-spaced");
		
		var nameIGAddon = document.createElement("span");
		$nameIGAddon = $(nameIGAddon);
		$nameIGAddon.attr("class", "input-group-addon");
		$nameIGAddon.html("Name");
		
		var nameIGField = document.createElement("input");
		$nameIGField = $(nameIGField);
		$nameIGField.attr("class", "form-control");
		$nameIGField.attr("type", "text");
		$nameIGField.attr("name", "extra_" + currentExtras + "_name");
		$nameIGField.attr("currExtra", currentExtras);
		
		$nameIGField.focusout(function () {
			var t = "#extra_" + $(this).attr("currExtra") + "_a";
			newName = $(this).val();
			// If there is any non-whitespace in the string
			if (/\S/.test(newName)) {
				$(t).html(newName);
			} else {
				var n = "Extra " + (parseInt($(this).attr("currExtra")) + 1)
				$(t).html(n);
			}
		});
		
		var sourceIG = document.createElement("div");
		$sourceIG = $(sourceIG);
		$sourceIG.attr("class", "input-group ig-spaced");
		
		var sourceIGAddon = document.createElement("span");
		$sourceIGAddon = $(sourceIGAddon);
		$sourceIGAddon.attr("class", "input-group-addon");
		$sourceIGAddon.html("Source");
		
		var sourceIGField = document.createElement("input");
		$sourceIGField = $(sourceIGField);
		$sourceIGField.attr("class", "form-control");
		$sourceIGField.attr("type", "text");
		$sourceIGField.attr("name", "extra_" + currentExtras + "_source");
		
		var costIG = document.createElement("div");
		$costIG = $(costIG);
		$costIG.attr("class", "input-group ig-spaced");
		
		var costIGAddon = document.createElement("span");
		$costIGAddon = $(costIGAddon);
		$costIGAddon.attr("class", "input-group-addon");
		$costIGAddon.html("Cost");
		
		var costIGField = document.createElement("input");
		$costIGField = $(costIGField);
		$costIGField.attr("class", "form-control");
		$costIGField.attr("type", "number");
		$costIGField.attr("name", "extra_" + currentExtras + "_cost");
		$costIGField.attr("currExtra", currentExtras);
		
		$costIGField.focusout(function() {
			if (parseInt($("#refresh_remaining_a").html()) <= $(this).val()) {
				$(this).val(0);
				alert("You don't have enough remaining Refresh for that!");
			} else {
				var currIndex = parseInt($(this).attr("currExtra"));
				var val = $(this).val();
				extraCosts[currIndex] = val;
			}
			updateCosts();
		});
		
		var descIG = document.createElement("div");
		$descIG = $(descIG);
		$descIG.attr("class", "input-group ig-spaced");
		
		var descIGAddon = document.createElement("span");
		$descIGAddon = $(descIGAddon);
		$descIGAddon.attr("class", "input-group-addon");
		$descIGAddon.html("Description");
		
		var descIGField = document.createElement("textarea");
		$descIGField = $(descIGField);
		$descIGField.attr("class", "form-control");
		$descIGField.attr("rows", "3");
		$descIGField.attr("name", "extra_" + currentExtras + "_description");
					
		$("#extras-tab-content").prepend($pane);

		$pane.append($row);
		$row.append($leftCol);
		$row.append($midCol);
		$row.append($rightCol);
	
		$leftCol.append($nameIG);
		$nameIG.append($nameIGAddon);
		$nameIG.append($nameIGField);
		
		$midCol.append($costIG);
		$costIG.append($costIGAddon);
		$costIG.append($costIGField);
		
		$rightCol.append($sourceIG);
		$sourceIG.append($sourceIGAddon);
		$sourceIG.append($sourceIGField);
		
		$row.append($fullCol);
		$fullCol.append($descIG);
		$descIG.append($descIGAddon);
		$descIG.append($descIGField);
				
		currentExtras++;
	});
});

function updateCosts() {
	console.log("Updating costs");
	var refreshRemaining = refresh;
	refreshRemaining -= currentStunts;
	for (i = 0; i < extraCosts.length; i++) {
		refreshRemaining -= extraCosts[i];
	}
	$("#refresh_remaining_a").html(refreshRemaining);
}

//Skills Stuff
function initializeSkillMap() {
	skillMap = [,,,,,,];
	for (i = 0; i < skillCols; i++) {
		skillMap[i] = [];
		for (x = 0; x < skillRows; x++) {
			skillMap[i].push(false);
		}
	}
}

function replaceLabel(item_id, newLabel) {
	console.log("settingInnerHTML");
	$("#" + item_id).html(newLabel);
}

function idToIndices(item_id) {
	var t = item_id.split("_");
	t.splice(t.indexOf("row"), 1);
	t.splice(t.indexOf("col"), 1);
	t.splice(t.indexOf("skill"), 1);
	t[0] = parseInt(t[0]);
	t[1] = parseInt(t[1]);
	return t;
}

function getSkillsOfPlus(row) {
	var val = 0;
	for (i = 0; i < skillCols; i++) {
		if (skillMap[i][row]) {
			val++;
		}
	}
	return val;
} 

function chooseSkill(item_id, newlabel) {
	var t = idToIndices(item_id);
	var rowcounter = "#skills_at_" + (skillRows - t[0]);
	var btn = $("#" + item_id).parent();
	if (newlabel == "(None)") {
		skillMap[t[1]][t[0]] = false;
		$(rowcounter).val(getSkillsOfPlus(t[0]));
	} else {
		skillMap[t[1]][t[0]] = true;
		$(rowcounter).val(getSkillsOfPlus(t[0]));
	}
	if (btn.attr("skill") != "(None)") {
		usedSkills.splice(btn.attr("skill"), 1)
		allSkills.push(btn.attr("skill"));
	} 
	allSkills.splice(allSkills.indexOf(newlabel), 1);
	if (newlabel != "(None)") {
		usedSkills.push(newlabel);
	}
	btn.attr("skill", "newlabel");
	replaceLabel(item_id, newlabel);
	newSkillSelection();
}

function newSkillSelection() {
	totalPoints();
	for (row = 0; row < skillRows; row++) {
		for (col = 0; col < skillCols; col++) {
			// Determines totals
//			console.log("Checking row " + row + " and col " + col);
			var id = "#row_" + row + "_col_" + col + "_skill";
			// Checks for skills, hiding them in dropdown as needed
//			console.log("hunting for " + id);
			var dropdownMenu = $(id).parent().siblings().children();
//			console.log(dropdownMenu);
//			console.log(dropdownMenu.get(0).innerHTML);
			for (i = 0; i < dropdownMenu.length; i++) {
				if (usedSkills.indexOf(dropdownMenu.get(i).firstChild.innerHTML) != -1) {
					dropdownMenu.get(i).style.display = 'none';
//					console.log("Hiding ");
				} else {
					if (dropdownMenu.get(i).style.display == 'none') {
						dropdownMenu.get(i).style.display = 'inline';
					}
				}
			}
			// Hides invalid buttons
//			console.log("Valid =" + validSkillSlots(row, col));
			if (validSkillSlots(row, col)) {
				$(id).parent().prop("disabled", false);
//				console.log("Setting row " + row + " col " + col + " to gold ");
//				console.log("Extra check - valid = " + validSkillSlots(row, col));
			} else {
				if (skillMap[col][row] == false) {
					$(id).parent().prop("disabled", true);
//					console.log("Setting row " + row + " col " + col + " to white ");
				}
			}
			// Sets (None) objects to low opacity
			if (skillMap[col][row] == false) {
				if ($(id).parent().prop("disabled") == false) {
					$(id).parent().fadeTo(20, 0.7);
				} else {
					$(id).parent().css('opacity', '');
				}
				$(id).parent().css('background-color', '');
			} else {
				$(id).parent().fadeTo(20, 1);
				$(id).parent().css('background-color', '#1B1B1B');
			}
		}
	}
}

function totalPoints() {
	var total = skillPoints;
	for (col = 0; col < skillCols; col++) {
		for (row = 0; row < skillRows; row++) {
			if (skillMap[col][row] == true) {
				total -= (5 - row);
			} 
			pointsRemaining = total;
		}
	}
	$("#skill_points_remaining").html(pointsRemaining.toString());
}

function validSkillSlots(row, col) {
	if (col > 0) {
		if (skillMap[col-1][row] == false) {
			return false;
		}
	}
//	console.log("called validSkillSlots on row " + row + " col " + col);
	if ((skillRows - row) > pointsRemaining) {
		console.log("Cost of " + (skillRows - row) + " greater than remaining points of " + pointsRemaining);
		return false;
	} else if (arrangement == "Pyramid") {
//		console.log("Arrangement is Pyramid");
		if (row == skillRows-1) {
//			console.log("Bottom row");
			return true;
		} else {
			if (col < skillCols-1) {
//				console.log("Col < skillCols -1");
				if ((skillMap[col+1][row+1] == true) && (skillMap[col][row+1] == true)) {
					return true;
				}
			} else {
//				console.log("Far right column")
				return false;
			}
		}
	} else if (arrangement == "Column") {
		if (row == skillRows-1) {
			return true;
		} else {
			if (skillMap[col][row+1] == true) {
				return true;
			} else {
				return false;
			}
		}
	} else {
		 return true;
	}
}