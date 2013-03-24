//slectで要素選んだら、即飛ぶよう
$("select").bind("change", function(event, ui) {
	var redirectTo = this.value;
	if (redirectTo.length) {
		location.href = redirectTo;
	}
});


//Blogsのlistview用
var scrollCheck = function() {
	var offset = $('#items > .item:last-child').offset();
	var top = offset ? offset.top : 0;
	if ($(window).scrollTop() + $(window).height() - top > 20) {
		next();
	}
}
function next() {
	count++;
	if(location.search){
		url = "blogs.json" + location.search + "&page=" + count;
	}
	else{
		url = "blogs.json" + "?page=" + count;
	}
	
	$.get(url, function(data) {
		document.URL.match(new RegExp(/blogs/));
		for (var i in data) {
			blog = data[i];
			$("<li><a href='" +　RegExp.leftContext + "blogs/" + blog.id + "' data-ajax=false>" + blog.title + "</a></li>").appendTo("ul#items");
		}
		$('ul').listview('refresh');
		$(window).scroll(scrollCheck);
	});
	$(window).unbind('scroll',scrollCheck);
}


$(document).ready(function() {
	count = 0;
	$(window).scroll(scrollCheck);
});
//Blogsのlistview用