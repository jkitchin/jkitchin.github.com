<%inherit file="site.mako" />
${entry['ID']}

<html>
<script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>
<body>

<h2><a href="https://doi.org/${entry.get('doi','no-doi')}">DOI</a></h2>
<table>
<tr>
<td>
<div data-badge-type='medium-donut' class='altmetric-embed' data-badge-details='right' data-doi='${entry.get('doi','no-doi')}'></div>
<object height="50" data="http://api.elsevier.com/content/abstract/citation-count?doi=${entry.get('doi','no-doi')}&amp;httpAccept=image/jpeg&amp;apiKey=5cd06d8a7df3de986bf3d0cd9971a47c"></object><br>

</td>
<td>
<pre>@article{${entry['ID']},
  author =	 {${entry.get('author', None)}},
  title =	 {${entry.get('title', None)}},
  journal =	 {${entry.get('journal', None)}},
  volume =	 ${entry.get('volume', None)},
  number =	 ${entry.get('number', None)},
  pages =	 ${entry.get('pages', None)},
  year =	 ${entry.get('year', None)},
  doi =		 {${entry.get('doi','no-doi')}}
}

</pre>

</td></tr></table>

<br>
<a href="https://webofknowledge.com">
<img alt="Web of Science" title="Web of Science" src="/wos_logo.png"></a>: <a href="http://ws.isiknowledge.com/cps/openurl/service?url_ver=Z39.88-2004&rft_id=info%3Adoi%2F${entry.get('doi','no-doi')}&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Asch_svc&svc.citing=yes">citing</a> <a href="http://ws.isiknowledge.com/cps/openurl/service?url_ver=Z39.88-2004&rft_id=info%3Adoi%2F${entry.get('doi','no-doi')}&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Asch_svc&svc.related=yes">related</a>
<br>






<a href="https://twitter.com/share" class="twitter-share-button">Tweet</a> <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
<script type="text/javascript" src="//www.reddit.com/buttonlite.js?i=1"></script>






<div id="disqus_thread"></div>
<script>
 /**
 * RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
 * LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables
 */
 /*
 var disqus_config = function () {
 this.page.url = PAGE_URL; // Replace PAGE_URL with your page's canonical URL variable
 this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
 };
 */
 (function() { // DON'T EDIT BELOW THIS LINE
 var d = document, s = d.createElement('script');

 s.src = '//cappa.disqus.com/embed.js';

 s.setAttribute('data-timestamp', +new Date());
 (d.head || d.body).appendChild(s);
 })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript" rel="nofollow">comments powered by Disqus.</a></noscript>


<script id="dsq-count-scr" src="//cappa.disqus.com/count.js" async></script>


<script type="text/javascript">
  var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
  document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
  try {
  var pageTracker = _gat._getTracker("UA-73115520-1");
  pageTracker._trackPageview();
  } catch(err) {}
</script>

</body></html>
