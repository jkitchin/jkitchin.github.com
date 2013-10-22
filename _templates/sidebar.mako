<aside>
<section>
Search
<form action="http://google.com/search" method="get">
  <fieldset role="search">
    <input type="hidden" name="q" value="site:jkitchin.github.io" />
    <input class="search" type="text" name="q" results="0" placeholder="Search"/>
  </fieldset>
</form>
</section>


  <section>
    <h1 class="post_header_gradient theme_font">Links</h1>
    <ul>
    <li><a href="http://enthought.com">Enthought Python</a></li>
    <li><a href="/pycse">Pycse</a></li>
    <li><a href="/dft-book">DFT-book</a></li>
    </ul>
  </section>

  <section>
    <h1 class="post_header_gradient theme_font">Latest Posts</h1>
    <ul>
      % for post in bf.config.blog.iter_posts_published(5):
      <li><a href="${post.path}">${post.title}</a></li>
      % endfor
    </ul>
  </section>

  <section>
 <h1 class="post_header_gradient theme_font"><a href="http://www.citeulike.org/user/jkitchin" class="external text" title="http://www.citeulike.org/user/jkitchin" rel="nofollow">CiteULike</a> Reading List</h1>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
<script type="text/javascript">
$(document).ready(function() {

var d = new Date();
curr_year = d.getFullYear();

$.getJSON('http://www.citeulike.org/json/user/jkitchin/,,?callback=?&per_page=5',
function(data) {
  var items = [];
  year=curr_year
  $.each(data, function(i) {
    year=data[i].published[0];
    var cit='<li id="' + i + '">' + '<a class="pap" href="http://dx.doi.org/'+data[i].doi+'">'+ data[i].title + '</a><br>';
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

  </section>

<section>
<h1 class="post_header_gradient theme_font">Latest GitHub Repos</h1>
  <a href="https://github.com/jkitchin">@jkitchin</a> on GitHub.
<ul id="my-github-projects">
    <li class="loading">Status updating&#8230;</li>
  </ul>

</section>
</aside>
