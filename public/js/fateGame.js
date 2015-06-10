var numAspects = 1;
var numSkills = 1;
var numTracks = 1;
var numConsequenceTypes = 1;
var numGMs = 1;
var numPlayers = 1;
var requiresApproval = false;

function incrementValue(id) {
//	console.log("incrementing " + id)
	$('#' + id).val($('#' + id).val() + 1);
}

function decrementValue(id) {
//	console.log("decrementing " + id);
	$('#' + id).val($('#' + id).val() - 1);
}

function addAspect() {
	var $inGroup = $("<div class='input-group' id='aspect_input_group_" + numAspects + "'></div>");
	var $typeLabel = $("<span class='input-group-addon'>Aspect Type</span>");
	var $aspectType = $("<input class='form-control' type='text' id='aspect_type_" + numAspects + "' name='aspect_type_" + numAspects + "'></input>");
	var $removeSpan = $("<span class='input-group-btn'></span>");
    var $removeButton = $("<button class='btn btn-default' type='button' onClick='removeAspect(" + numAspects + ")' + id='remove_aspect_" + numAspects + "_button'>Remove</button>");
    
    $inGroup.append($typeLabel);
    $inGroup.append($aspectType);
    $inGroup.append($removeSpan);
    $removeSpan.append($removeButton);
    console.log($inGroup);
    
    $('#add_aspect_button').before($inGroup);

    incrementValue("num_aspects");
    numAspects++;
}

function removeAspect(num) {
    $('#aspect_input_group_' + num).remove();
    for (x = num + 1; x < numAspects; x++) {
        var t = x-1;
        
        $('#aspect_input_group_' + x).attr('id', 'aspect_input_group' + t);
        
        $('#aspect_type_' + x).attr({
        	id: 'aspect_type_' + t,
        	name: 'aspect_type_' + t
        });
        
        $('#remove_aspect_' + x + '_button').attr({
        	id: 'remove_aspect_' + t + '_button',
        	onClick: 'removeAspect(' + t + ')'
        });     
    }
	decrementValue("num_aspects")
	numAspects--;
}

function addSkill() {
	var $inGroup = $("<div class='input-group' id='skill_input_group_" + numSkills + "'></div>");
	var $skillLabel = $("<span class='input-group-addon'>Skill</span>");
    var $skillName = $("<input class='form-control' type='text' id='skill_name_" + numSkills + "' name='skill_name_" + numSkills + "'></input>");
    var $removeSpan = $("<span class='input-group-btn'></span>");
    var $removeButton = $("<button class='btn btn-default' type='button' onClick='removeSkill(" + numSkills + ")' id='remove_skill_" + numSkills + "_button'>Remove</button>");
    
    $inGroup.append($skillLabel);
    $inGroup.append($skillName);
    $inGroup.append($removeSpan);
    $removeSpan.append($removeButton);    
    
    $("#add_skill_button").before($inGroup);
    
    incrementValue("num_skills");
    numSkills++;
}

function removeSkill(num) {
	$("#skill_input_group_" + num).remove();
    for (x = num + 1; x < numSkills; x++) {
        var t = x-1;
        
        $('#skill_input_group_' + x).attr('id', 'skill_input_group_' + t);
        
        $('#skill_name_' + x).attr({
        	id: 'skill_name_' + t,
        	name: 'skill_name_' + t
        });
        
        $('#remove_skill_' + x + '_button').attr({
        	id: 'remove_skill_' + t + '_button',
        	onClick: 'removeSkill(' + t + ')'
        });  
    }
    decrementValue("num_skills");
    numSkills--;
}

function addTrack() {
	var $inGroupA = $('<div class="input-group"></div>');
	var $nameLabel = $('<span class="input-group-addon">Name</span>');
	var $nameField = $('<input class="form-control" type="text" name="stress_track_' + numTracks + '_name" id="stress_track_' + numTracks + '_name"></input>');
	
	var $inGroupB = $('<div class="input-group"></div>');
	var $numLabel = $('<span class="input-group-addon">Boxes</span>'); 
	var $numBoxes = $('<input class="form-control" type="number" name="stress_track_' + numTracks + '_size" id="stress_track_' + numTracks + '_size"></input>');
		
	var $inGroupC = $('<div class="input-group"></div>');
	var $skillLabel = $('<span class="input-group-addon">Skill</span>');
	var $skillField = $('<input class="form-control" type="text" name="stress_track_' + numTracks + '_skill" id="stress_track_' + numTracks + '_skill"></input>');
	
	var $removeSpan = $('<span class="input-group-btn"></span>');
	var $removeButton = $('<button class="btn btn-default" type="button" onClick="removeTrack(' + numTracks + ')" id="remove_track_' + numTracks + '_button">Remove</button>');
	
	var $row = $('<div class="row" id="stress_track_row_' + numTracks + '"></div>');
	var $col1 = $('<div class="col-lg-3"></div>');
	var $col2 = $('<div class="col-lg-3"></div>');
	var $col3 = $('<div class="col-lg-4"></div>');
	var $col4 = $('<div class="col-lg-2"></div>');
	
	$inGroupA.append($nameLabel);
	$inGroupA.append($nameField);
	
    $inGroupB.append($numLabel);
    $inGroupB.append($numBoxes);
    
    $inGroupC.append($skillLabel);
    $inGroupC.append($skillField);
    
    $removeSpan.append($removeButton);
    
    $col1.append($inGroupA);
    $col2.append($inGroupB);
    $col3.append($inGroupC);
    $col4.append($removeSpan);
    
    $row.append($col1, $col2, $col3, $col4);
    
    $("#add_track_button").before($row);
    
    incrementValue("num_stress_tracks");
    numTracks++;
}

function removeTrack(num) {
    $('#stress_track_row_' + num).remove();
    
    for (x = num + 1; x < numTracks; x++) {
        var t = x-1;
        
        $('#stress_track_row_' + x).attr('id', 'stress_track_row_' + t);
        
        $('#stress_track_' + x + '_name').attr({
        	name: 'stress_track_' + t + '_name',
        	id: 'stress_track_' + t + '_name'
        });
        
        $('#stress_track_' + x + '_size').attr({
        	name: 'stress_track_' + t + '_size',
        	id: 'stress_track_' + t + '_size'
        });
        
        $('remove_track_button_' + x).attr({
        	id: 'remove_track_' + t + '_button',
        	onClick: 'removeTrack(' + t + ')'
        });
    }
    decrementValue("num_stress_tracks");
    numTracks--;
}

function addConsequenceType() {
	var $row = $("<div class='row' id='consequences_row_" + numConsequenceTypes + "'></div>");
	var $col1 = $("<div class='col-lg-5'></div>");
	var $inputGroup1 = $("<div class='input-group'></div>");
	var $groupLabel = $("<span class='input-group-addon'>Group</span>");
	var $groupNameInput = $("<input class='form-control' type='text' name='consequence_type_" 
			+ numConsequenceTypes + "_name' id='consequence_type_" + numConsequenceTypes + "_name'>");
	
	var $col2 = $("<div class='col-lg-5'></div>");
	var $inputGroup2 = $("<div class='input-group'></div>");
	var $sizesLabel = $("<span class='input-group-addon'>Sizes</span>");
	var $sizesInput = $("<input class='form-control' type='text' name='consequence_type_" +
			+ numConsequenceTypes + "_sizes' id='consequence_type_" + numConsequenceTypes + "_sizes'>");
	
	var $col3 = $("<div class='col-lg-2'></div>");
	
	var $removeButtonSpan = $("<span class='input-group-btn'></span>");
	var $removeButton = $("<button class='btn btn-default' type='button' onClick='removeConsequenceType(" +
			numConsequenceTypes + ")' id='remove_consequence_type_" + numConsequenceTypes + "_button'>Remove</button>");
	
	$row.append($col1);
	$row.append($col2);
	$row.append($col3);
	
	$col1.append($inputGroup1);
	$col2.append($inputGroup2);
	$col3.append($removeButtonSpan);
	
	$inputGroup1.append($groupLabel);
	$inputGroup1.append($groupNameInput);
	
	$inputGroup2.append($sizesLabel);
	$inputGroup2.append($sizesInput);
	
	$removeButtonSpan.append($removeButton);
	
    $("#add_consequence_type_button").before($row);
    
    incrementValue("num_consequence_types");
    numConsequenceTypes++;
}

function removeConsequenceType(num) {
    var row = document.getElementById("consequences_row_" + num);
    row.parentNode.removeChild(row);
    for (x = num + 1; x < numConsequenceTypes; x++) {
        var t = x-1;
        
        var nRow = document.getElementById("consequences_row_" + x);
        nRow.setAttribute("id", "consequences_row_" + t);
        
        var nameField = document.getElementById("consequence_type_" + x + "_name");
        nameField.setAttribute("name", "consequence_type_" + t + "_name");
        nameField.setAttribute("id", "consequence_type_" + t + "_name");
        
        var numBoxes = document.getElementById("consequence_type_" + x + "_sizes")
        numBoxes.setAttribute("name", "consequence_type_" + t + "_sizes");
        numBoxes.setAttribute("id", "consequence_type_" + t + "_sizes");
        
        var rmBtn = document.getElementById("remove_consequence_type_" + x + "_button");
        rmBtn.setAttribute("id", "remove_consequence_type_" + t + "_button");
        rmBtn.setAttribute("onClick", "removeConsequenceType(" + t + ")");
        
    }
    decrementValue("num_consequence_types");
    numConsequenceTypes--;
}

function addGM() {
	var inGroup = document.createElement("div");
	inGroup.setAttribute("class", "input-group");
	inGroup.setAttribute("id", "gm_input_group_" + numGMs);
	
	var usernameLabel = document.createElement("span");
	usernameLabel.setAttribute("class", "input-group-addon");
	usernameLabel.appendChild(document.createTextNode("Username"));
	
	var username = document.createElement("input");
	username.setAttribute("class", "form-control");
	username.setAttribute("type", "text");
	username.setAttribute("id", "gm_username_" + numGMs);
	username.setAttribute("name", "gm_username_" + numGMs);
	
	var removeSpan = document.createElement("span");
	removeSpan.setAttribute("class", "input-group-btn");
	
	var removeButton = document.createElement("button");
	removeButton.setAttribute("class", "btn btn-default");
	removeButton.setAttribute("type", "button");
	removeButton.setAttribute("onClick","removeGM(" + numGMs + ")");
	removeButton.setAttribute("id", "remove_gm_" + numGMs + "_button");
	removeButton.appendChild(document.createTextNode("Remove"));
	
	inGroup.appendChild(usernameLabel);
	inGroup.appendChild(username);
	inGroup.appendChild(removeSpan);
	removeSpan.appendChild(removeButton);
	
	var body = document.getElementById("gms_body");
	var btn = document.getElementById("add_gm_button");
	body.insertBefore(inGroup, btn);
	
	incrementValue("num_gms");
	numGMs++;	    
}

function removeGM(num) {
    var inGroup = document.getElementById("gm_input_group_" + num);
    inGroup.parentNode.removeChild(inGroup);
    for (x = num + 1; x < numGMs; x++) {
        var t = x-1;
        
        var inG = document.getElementById("gm_input_group_" + x);
        inG.setAttribute("id", "gm_input_group_" + t);
        
        var GMName = document.getElementById("gm_username_" + x);
        GMName.setAttribute("id", "gm_username_" + t);
        GMName.setAttribute("name", "gm_username_" + t);
        
        var rmBtn = document.getElementById("remove_gm_" + x + "_button");
        rmBtn.setAttribute("id", "remove_gm_" + t + "_button");
        rmBtn.setAttribute("onClick", "removeGM(" + t + ")");       
    }
    decrementValue("num_gms");
    numGMs--;
}

function addPlayer() {
	var inGroup = document.createElement("div");
	inGroup.setAttribute("class", "input-group");
	inGroup.setAttribute("id", "player_input_group_" + numPlayers);
	
	var usernameLabel = document.createElement("span");
	usernameLabel.setAttribute("class", "input-group-addon");
	usernameLabel.appendChild(document.createTextNode("Username"));
	
	var username = document.createElement("input");
	username.setAttribute("class", "form-control");
	username.setAttribute("type", "text");
	username.setAttribute("id", "player_username_" + numPlayers);
	username.setAttribute("name", "player_username_" + numPlayers);
	
	var removeSpan = document.createElement("span");
	removeSpan.setAttribute("class", "input-group-btn");
	
	var removeButton = document.createElement("button");
	removeButton.setAttribute("class", "btn btn-default");
	removeButton.setAttribute("type", "button");
	removeButton.setAttribute("onClick", "removePlayer(" + numPlayers + ")");
	removeButton.setAttribute("id", "remove_player_" + numPlayers + "_button");
	removeButton.appendChild(document.createTextNode("Remove"));
	
	inGroup.appendChild(usernameLabel);
	inGroup.appendChild(username);
	inGroup.appendChild(removeSpan);
	removeSpan.appendChild(removeButton);
	
	var body = document.getElementById("players_body");
	var btn = document.getElementById("add_player_button");
	body.insertBefore(inGroup, btn);
	
	incrementValue("num_players");
	numPlayers++;	    
}

function removePlayer(num) {
    var inGroup = document.getElementById("player_input_group_" + num);
    inGroup.parentNode.removeChild(inGroup);
    for (x = num + 1; x < numGMs; x++) {
        var t = x-1;
        
        var inG = document.getElementById("player_input_group_" + x);
        inG.setAttribute("id", "player_input_group_" + t);
        
        var playerName = document.getElementById("player_username_" + x);
        playerName.setAttribute("id", "player_username_" + t);
        playerName.setAttribute("name", "player_username_" + t);
        
        var rmBtn = document.getElementById("remove_player_" + x + "_button");
        rmBtn.setAttribute("id", "remove_player_" + t + "_button");
        rmBtn.setAttribute("onClick", "removePlayer(" + t + ")");       
    }
    decrementValue("num_players");
    numPlayers--;
}

function replacePresetsLabel(newLabel) {
	var label = document.getElementById("presets_top_label");
	label.innerHTML = newLabel;
}

function skillArrangementChange(newArrangement) {
	var label = document.getElementById("arrangement_top_label");
	label.innerHTML = newArrangement;
	var field = document.getElementById("skill_arrangement");
	field.value=newArrangement;
}

function toggleRequiresApprovalText() {
	console.log("called requiresApproval");
	var txt = document.getElementById("requires_approval_current");
	if (requiresApproval == false) {
		txt.innerHTML = "Yes";
		requiresApproval = true;
	} else {
		txt.innerHTML = " No";
		requiresApproval = false;
	}
}

var presetsTest;

function getPresets() {
	$.get('/presets/games/fate', function (data) {
		presetsTest = data;
	},
	"json");
}

function implementPresetJSON(presetInfo) {
	var preset = JSON.parse(presetInfo);
	implementPreset(preset.label, preset.vars, preset.aspectTypes, preset.skillNames, preset.skillPoints, preset.skillArrangement, preset.stressTracks, preset.consequenceInfo, preset.refresh, preset.stuntInfo);
}

function implementPreset(newLabel, presetVars, aspectTypes, skills, skillPoints, arrangement, stressTracks, consequences, refresh, stuntInfo) {
	replacePresetsLabel(newLabel);
	universalPresetCleanup(aspectTypes.length, skills.length, stressTracks.length, consequences.length);
	for (i = 0; i < aspectTypes.length; i++) {
		$("#aspect_type_" + i).val(aspectTypes[i]);
	}
	for (i = 0; i < skills.length; i++) {
		$("#skill_name_" + i).val(skills[i]);
	}
	$("#num_skill_points").val(skillPoints);
	skillArrangementChange(arrangement);
	for (i = 0; i < stressTracks.length; i++) {
		$("#stress_track_" + i + "_name").val(stressTracks[i].name);
		$("#stress_track_" + i + "_size").val(stressTracks[i].size);
		$("#stress_track_" + i + "_skill").val(stressTracks[i].skill);
	}
	for (i = 0; i < consequences.length; i++) {
		$("#consequence_type_" + i + "_name").val(consequences[i].name);
		$("#consequence_type_" + i + "_sizes").val(consequences[i].sizes);
	}
	$("#pc_refresh").val(refresh);
	$("#num_stunts").val(stuntInfo[0]);
	$("#num_max_stunts").val(stuntInfo[1]);
}

var fateCorePreset = '{"label": "Fate Core",' +
'"aspectTypes": ["High Concept", "Trouble", "Phase 1", "Phase 2", "Phase 3"],' +
'"skillNames": ["Athletics", "Burglary", "Contacts", "Crafts", "Deceive", "Drive", "Empathy", "Fight", "Investigate", "Lore", "Notice", "Physique", "Provoke", "Rapport", "Resources", "Shoot", "Stealth", "Will"],' +
'"skillPoints": 20,' +
'"skillArrangement": "Pyramid",' +
'"stressTracks": [{"name": "Physical", "size": 2, "skill": "Physique"}, {"name": "Mental", "size": 2, "skill": "Will"}],' +
'"consequenceInfo": [{"name": "Shared", "sizes": "-2, -4, -6"}],' +
'"refresh": 6,' +
'"stuntInfo": {"minStunts": 3, "maxStunts": 5}}';

var fireflyPreset = '{"label": "Firefly",' +
'"aspectTypes": ["High Concept", "Trouble", "Role Amongst the Crew", "Call of the Black", "What Keeps You Going"],' +
'"skillNames": ["Athletics", "Brawl", "Company", "Culture", "Doctor", "Fence", "Fly", "Hustle", "Inspect", "Instinct", "Mechanics", "Rob", "Physique", "Preach", "Provoke", "Shoot", "Stealth", "Will", "Read"],' +
'"skillPoints": 20,' +
'"skillArrangement": "Pyramid",' +
'"stressTracks": [{"name": "Physical", "size": 2, "skill": "Physique"}, {"name": "Mental", "size": 2, "skill": "Will"}],' +
'"consequenceInfo": [{"name": "Shared", "sizes": "-2, -4, -6"}],' +
'"refresh": 6,' +
'"stuntInfo": {"minStunts": 3, "maxStunts": 5}}';

var kriegzeppelinPreset = '{"label": "Kriegzeppelin Valkyrie",' +
'"aspectTypes": ["High Concept", "Trouble", "Free", "Free", "During Play"],' +
'"skillNames": ["Athletics", "Deceive", "Empathy", "Fight", "Machinery", "Notice", "Physique", "Pilot", "Rapport", "Shoot", "Swagger", "Stealth", "Will"],' +
'"skillPoints": 20,' +
'"skillArrangement": "Pyramid",' +
'"stressTracks": [{"name": "Physical", "size": 2, "skill": "Physique"}, {"name": "Mental", "size": 2, "skill": "Will"}],' +
'"consequenceInfo": [{"name": "Shared", "sizes": "-2, -4, -6"}],' +
'"refresh": 6,' +
'"stuntInfo": {"minStunts": 3, "maxStunts": 5}}';

function universalPresetCleanup(presetNumAspects, presetNumSkills, presetNumTracks, presetNumConsequenceTypes) {
	// Handles number of aspects
	if (presetNumAspects > numAspects) {
		for (i = numAspects; i < presetNumAspects; i++) {
			addAspect();
		}
	} else {
		for (i = numAspects; i > presetNumAspects; i--) {
			removeAspect(i);
		}
	}
	// Handles number of skills
	if (presetNumSkills > numSkills) {
		for (i = numSkills; i < presetNumSkills; i++) {
			addSkill();
		}
	} else {
		for (i = numSkills; i > presetNumSkills; i--) {
			removeSkill(i-1);
		}
	}
	// Handles number of stress tracks
	if (presetNumTracks > numTracks) {
		for (i = numTracks; i < presetNumTracks; i++) {
			addTrack();
		}
	} else {
		for (i = numTracks; i > presetNumTracks; i--) {
			removeTrack(i-1);
		}
	}
	// Handles number of consequence types
	if (presetNumConsequenceTypes > numConsequenceTypes) {
		for (i = numConsequenceTypes; i < presetNumConsequenceTypes; i++) {
			addConsequenceType();
		}
	} else {
		for (i = numConsequenceTypes; i > presetNumConsequenceTypes; i--) {
			removeConsequenceType(i-1);
		}
	}
}

$(document).ready(function() {
	if ($("#permissions").val() == "Edit") {
		// Game name edit stuff
		$("#submit_gamename_change").click(function() {
			var url = "/edit/game/fate/" + $("#post-game-name").val() + "/name";
			$.post(
				url, 
				{new_val: $("#edit_game_name").val() },
				function(data, status, xhr) {
					window.location.replace("/view/games/fate/" + $("#edit_game_name").val())
					$("edit_game_name").prop("disabled", true);
					$("submit_gamename_change").hide();
				}
			);
					
		});
		$("#submit_gamename_change").hide();
		$("#show_gamename_field").click(function() {
			$("#edit_game_name").prop("disabled", false);
			$("#submit_gamename_change").show();
		});
		// Setting name change edit stuff
		$("#submit_settingname_change").click(function() {
			var url = "/edit/game/fate/" + $("#post-game-name").val() + "/setting_name";
			$.post(
				url, 
				{new_val: $("#edit_setting_name").val() },
				function(data, status, xhr) {
					$("#edit_setting_name").prop("disabled", true);
					$("#submit_settingname_change").hide();
				}
			);
					
		});
		$("#submit_settingname_change").hide();
		$("#show_settingname_field").click(function() {
			$("#edit_setting_name").prop("disabled", false);
			$("#submit_settingname_change").show();
		});
		// Aspect change edit stuff
		$('[id^="submit_aspect_"][id$="_change"]').each(function() {
			$(this).click(function() {
				$t = $((this).parents().get(2));
				var url = "/edit/game/fate/" + $("#post-game-name").val() + "/aspects";
				$.post(
					url,
					{new_val: getAspectsArray()},
					function(data, status, xhr) {
						$t.find('[id^="edit_aspect"]').prop("disabled", true);
						$t.find('[id^="submit_aspect"]').hide();
						$t.find('[id^="delete_aspect"]').hide();
					}
				);
			});
			$(this).hide();
		});
		
		$('[id^="delete_aspect_"][id$="_button"]').each(function() {
			$(this).click(function() {
				$t = $(this);
				var id = $t.attr("id").charAt($t.attr("id").search(/\d/));
				var url = "/edit/game/fate/" + $("#post-game-name").val() + "/aspects";
				console.log(getAspectsArray());
				var asp = getAspectsArray();
				asp.splice(id, 1);
				console.log(asp);
				$.post(
					url,
					{new_val: asp },
					function(data, status, xhr) {
						window.location.replace("/view/games/fate/" + $("#edit_game_name").val())
					}
				);
			});	
			$(this).hide();
		});
		
		$('[id^="show_aspect_"],[id$="_field"]').each(function() {
			$(this).click(function() {
				$td = $($(this).parents().get(1))
				
				$td.siblings().find('[id^="edit_aspect"]').prop("disabled", false);
				$td.siblings().find('[id^="submit_aspect"]').show();
				$td.siblings().find('[id^="delete_aspect"]').show();
			});
		});
		
	}
});

function getAspectsArray() {
	var arr = [];
	for (i = 0; i < $("#num_aspects").val(); i++) {
		arr.push($("#edit_aspect_" + i + "_name").val());
	}
	return arr;
}