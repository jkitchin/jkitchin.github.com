<%inherit file="_templates/site.mako" />
<article class="page_box">

<p><b>Browse my reading list on <a href="http://www.citeulike.org/user/jkitchin" class="external text" title="http://www.citeulike.org/user/jkitchin" rel="nofollow">CiteULike</a></b>
</p><p>
<style type="text/css">
li{
padding-bottom:5px;
}
a.pap{
font-weight:bold;
}
.journal{
font-weight:bold;

}
</style>

<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
<script type="text/javascript">
$(document).ready(function() {

var d = new Date();
curr_year = d.getFullYear();

$.getJSON('http://www.citeulike.org/json/user/jkitchin//order/year,,?callback=?&per_page=10',
function(data) {
  var items = [];
  year=curr_year
  $.each(data, function(i) {
    if (data[i].published[0]!==year){
         items.push( '<h3>' + data[i].published[0] + '</h3>');
    }
    year=data[i].published[0];
    var cit='<li id="' + i + '">' + '<a class="pap" href="https://doi.org/'+data[i].doi+'">'+ data[i].title + '</a><br>';
    cit+='</li>';
    items.push( cit )
  });

  $('<ul/>', {
    'class': 'my-new-list',
    html: items.join('')
  }).appendTo('#papers2');
});
});
</script>

<div id="papers2"></div>

<%self:filter chain="markdown">


</%self:filter>
</article>
