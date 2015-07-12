$("document").ready(function() {
	$("#add_paragraph").click(addParagraph);
	$("#remove_paragraph").click(removeParagraph);
	$("#submit_button").click(submit_crawl);
});

function combineParagraphs() {
	var all_pars = $("textarea");
	var par_string = '';
	for (var i = 0; i < all_pars.length; i++) {
		var temp_string = all_pars[i].value;
		temp_string = temp_string.replace(new RegExp(/\n|\r/g), ' ');
		par_string = par_string.concat(temp_string);
		if (i < all_pars.length-1) {
			par_string += '\n'
		}
	}
	return par_string;
}

function addParagraph() {
	$("#add_paragraph").before('<div class="form-group"><label for="contents">Paragraph</label><textarea class="form-control" rows="5"></textarea></div>');
	console.log("Appended");
}

function removeParagraph() {
	var pars = $("textarea");
	$(pars[pars.length-1]).parent().remove();
}

function submit_crawl() {
	data_fields = {"crawlname": $("#name").val(),
					"contents": combineParagraphs()};
	$.ajax({
		type: "POST",
		url: '/crawls/make',
		data: data_fields
	}).done(function(data) {
		window.location.href=('/crawls/view/' + $("#name").val());
	});
}