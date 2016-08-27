<%inherit file="../_templates/site.mako" /><script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script><div id="outline-container-orgheadline1" class="outline-2">
<h2 id="orgheadline1"><span class="section-number-2">1</span> <span class="done DONE">DONE</span> Using Twitter cards for better tweets</h2>
<div class="outline-text-2" id="text-1">

<div class="figure">
<p><img src="./ss-vdw.png" alt="ss-vdw.png" />
</p>
</div>

<div class="org-src-container">

<pre class="src src-bibtex"><span style="color: #006699;">@article</span>{<span style="color: #D0372D;">thirumalai-2015-pt-pd</span>,
  <span style="color: #BA36A5;">author</span> =       "Hari Thirumalai and John R. Kitchin",
  <span style="color: #BA36A5;">title</span> =        {The Role of Vdw Interactions in Coverage Dependent Adsorption
                  Energies of Atomic Adsorbates on Pt(111) and Pd(111)},
  <span style="color: #BA36A5;">journal</span> =      "Surface Science ",
  <span style="color: #BA36A5;">pages</span> =        " - ",
  <span style="color: #BA36A5;">year</span> =         2015,
  <span style="color: #BA36A5;">doi</span> =          {<span style="color: #006DAF; text-decoration: underline;">10.1016/j.susc.2015.10.001</span>},
  <span style="color: #BA36A5;">url</span> =
                  "http://www.sciencedirect.com/science/article/pii/S0039602815003052",
  <span style="color: #BA36A5;">issn</span> =         "0039-6028",
}
</pre>
</div>

<div data-badge-details="right" data-badge-type="medium-donut" data-doi="10.1016/j.susc.2015.10.001" data-hide-no-mentions="true" class="altmetric-embed"></div>
<p>
See it here: <a href="http://www.sciencedirect.com/science/article/pii/S0039602815003052">http://www.sciencedirect.com/science/article/pii/S0039602815003052</a>.
</p>

<p>
The main goal of this post is to test run using a <a href="https://dev.twitter.com/cards/types/summary-large-image">Twitter card</a> to make better tweets about publications.
</p>

<p>
This post did not work quite like I anticipated, mostly because of the way I publish my blog which focuses only on the HTML body. The meta tags that are needed for Twitter do not seem to get put in the header as needed. If I do a regular org export with HTML_HEAD options to get this page: <a href="http://kitchingroup.cheme.cmu.edu/publications/twitter-card.html">http://kitchingroup.cheme.cmu.edu/publications/twitter-card.html</a>, it did work. The page is pretty bare, but it could be embellished without much work. 
</p>

<p>
Tweeting that URL led to this tweet: 
</p>

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Test tweet with a twitter card: <a href="https://t.co/TagjgTgFmZ">https://t.co/TagjgTgFmZ</a></p>&mdash; John Kitchin (@johnkitchin) <a href="https://twitter.com/johnkitchin/status/769267071645540352">August 26, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<p>
On Twitter, this showed an image of the picture on the page, and linked directly to the page I made. The image is sized a little large and doesn't fit in card quite right, but this is probably fixable. This whole process could be smoothed out a lot with a custom export to get the twitter meta tags in the right place, and maybe provide links to bibtex files, analytics, etc. Sounds like a fun project ;) 
</p>
</div>
</div>
