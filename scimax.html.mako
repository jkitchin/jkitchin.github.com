<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgadae9d3">1. Scientific research</a></li>
<li><a href="#orgd2afdc3">2. Scientific publishing</a></li>
<li><a href="#org1293239">3. Build interactive apps</a>
<ul>
<li><a href="#orgc35e584">3.1. org-ref</a></li>
<li><a href="#org8a77bd5">3.2. contacts</a></li>
</ul>
</li>
<li><a href="#org8ec2bea">4. Teaching</a></li>
</ul>
</div>
</div>
<%inherit file="_templates/site.mako" />

<h1>sci<font color="#4863A0">max</font></h1><br><h3>bringing plain text to life</h3>


<p>
<a href="https://github.com/jkitchin/scimax">Scimax</a> is a set of open-source software tools to integrate narrative text with data, code, figures, equations, tables and citations. Scimax brings plain text to life by making it functional and interactive. With scimax you can embed and run code directly in your documents, and capture the output in your document. You can embed data in your documents with narrative text that explains what it is, and then use the document as a data source for analysis. You can easily convert documents written with scimax to HTML, LaTeX, PDF, even MS Word.
</p>

<p>
Scimax builds on Emacs, <a href="http://orgmode.org">org-mode</a> and programming tools to provide a rich authoring environment for writing, programming, research and teaching.
</p>


<div class="figure">
<p><img src="./media/scimax-graphic.jpg" alt="scimax-graphic.jpg" />
</p>
</div>

<div id="outline-container-orgadae9d3" class="outline-2">
<h2 id="orgadae9d3"><span class="section-number-2">1</span> Scientific research</h2>
<div class="outline-text-2" id="text-1">
<p>
We use scimax as an electronic notebook in all our research. scimax lets us integrate narrative text with citations about what we are trying to do with data and code to perform analysis. scimax integrates project/task management tools and distributed version control tools to enable collaboration in our group.
</p>

<p>
You can see a precursor to scimax  in this presentation at Scipy-2013.
</p>

<iframe width="560" height="315" src="https://www.youtube.com/embed/1-dUkyn_fZA" frameborder="0" allowfullscreen></iframe>
</div>
</div>


<div id="outline-container-orgd2afdc3" class="outline-2">
<h2 id="orgd2afdc3"><span class="section-number-2">2</span> Scientific publishing</h2>
<div class="outline-text-2" id="text-2">
<p>
We write all our scientific manuscripts using scimax. After the documents are written, we use scimax to convert them to the format required by publishers (usually LaTeX). These manuscripts and their supporting information files contain all the data, code and analysis we used in the papers so others can see what we did, and even reuse the data/code.
</p>

<ul class="org-ul">
<li><a class='org-ref-reference' href="#hallenbeck-2013-effec-o2">hallenbeck-2013-effec-o2</a> Experimental</li>
<li><a class='org-ref-reference' href="#miller-2014-simul-temper">miller-2014-simul-temper</a> Combined experimental and computational</li>
<li><a class='org-ref-reference' href="#curnan-2014-effec-concen">curnan-2014-effec-concen</a> Computational</li>
<li><a class='org-ref-reference' href="#xu-2014-probin-cover">xu-2014-probin-cover</a> Computational</li>
<li><a class='org-ref-reference' href="#xu-2014-relat">xu-2014-relat</a> Computational</li>
<li><a class='org-ref-reference' href="#mehta-2015-ident-poten">mehta-2015-ident-poten</a> Computational</li>
<li><a class='org-ref-reference' href="#boes-2015-estim-bulk">boes-2015-estim-bulk</a> Combined experimental and computational</li>
<li><a class='org-ref-reference' href="#boes-2015-estim-bulk-si">boes-2015-estim-bulk-si</a></li>
<li><a class='org-ref-reference' href="#kitchin-2015-examp">kitchin-2015-examp</a> Perspective</li>
<li><a class='org-ref-reference' href="#kitchin-2015-data-surfac-scien">kitchin-2015-data-surfac-scien</a> Perspective</li>
<li><a class='org-ref-reference' href="#xu-2015-accur-u">xu-2015-accur-u</a> Computational</li>
<li><a class='org-ref-reference' href="#xu-2015-linear-respon">xu-2015-linear-respon</a> Computational</li>
<li><a class='org-ref-reference' href="#xu-2015-relat">xu-2015-relat</a> Computational</li>
<li><a class='org-ref-reference' href="#xu-2015-tunin-oxide">xu-2015-tunin-oxide</a> Computational</li>
<li><a class='org-ref-reference' href="#boes-2017-model-segreg">boes-2017-model-segreg</a> Computational</li>
<li><a class='org-ref-reference' href="#boes-2017-neural-networ">boes-2017-neural-networ</a> Computational</li>
<li><a class='org-ref-reference' href="#geng-2017-first-princ">geng-2017-first-princ</a> Computational</li>
<li><a class='org-ref-reference' href="#xu-2017-first-princ">xu-2017-first-princ</a> Computational</li>
<li><a class='org-ref-reference' href="#kitchin-2017-autom-data">kitchin-2017-autom-data</a> Publishing and data-sharing</li>
<li><a class='org-ref-reference' href="#wang-2018-densit-funct">wang-2018-densit-funct</a> Computational</li>
<li><a class='org-ref-reference' href="#gao-2018-model-pallad">gao-2018-model-pallad</a> Computational</li>
<li><a class='org-ref-reference' href="#thirumalai-2018-inves-react">thirumalai-2018-inves-react</a> Computational</li>
<li><a class='org-ref-reference' href="#kitchin-2018-machin-learn-catal">kitchin-2018-machin-learn-catal</a> Perspective</li>
</ul>

<p>
We have written two large electronic books using scimax. These books integrate narrative discussion with code, data, equations, figures, tables and citations. In the native format, they are interactive and functional.
</p>
<ul class="org-ul">
<li><a href="http://kitchingroup.cheme.cmu.edu/pycse">Python computation in science and engineering</a></li>
<li><a href="http://kitchingroup.cheme.cmu.edu/dft-book">Modeling materials with density functional theory</a></li>
</ul>

<p>
Finally, this blog is written using scimax.
</p>
<ul class="org-ul">
<li>blog <a href="http://kitchingroup.cheme.cmu.edu">http://kitchingroup.cheme.cmu.edu</a></li>
</ul>
</div>
</div>

<div id="outline-container-org1293239" class="outline-2">
<h2 id="org1293239"><span class="section-number-2">3</span> Build interactive apps</h2>
<div class="outline-text-2" id="text-3">
<p>
We have built two significant apps on top of the tools in scimax.
</p>
</div>

<div id="outline-container-orgc35e584" class="outline-3">
<h3 id="orgc35e584"><span class="section-number-3">3.1</span> org-ref</h3>
<div class="outline-text-3" id="text-3-1">
<p>
org-ref is a bibliography management tool similar to Endnote. It provides tools to insert citations and bibliographies in documents. The citations are hyper-functional, and connect your documents to external search engines, locally stored pdf files, etc.
</p>
</div>
</div>

<div id="outline-container-org8a77bd5" class="outline-3">
<h3 id="org8a77bd5"><span class="section-number-3">3.2</span> contacts</h3>
<div class="outline-text-3" id="text-3-2">
<p>
This is a contact manager for scimax. It allows you to quickly find contacts, email them, call them, etc. It can mine your email database for contact information
</p>
</div>
</div>
</div>

<div id="outline-container-org8ec2bea" class="outline-2">
<h2 id="org8ec2bea"><span class="section-number-2">4</span> Teaching</h2>
<div class="outline-text-2" id="text-4">
<p>
<a href="https://github.com/jkitchin/techela">techela</a> is a tool based on scimax that acts like a content management system for teaching a class. It provides a framework to distribute, collect, grade and return assignments and course materials. techela provides an integrated gradebook, and communication tools.
</p>

<p>
Here is a video of this tool in the precursor to scimax.
</p>

<p>
<h1 class='org-ref-bib-h1'>Bibliography</h1>
<ul class='org-ref-bib'><li><a id="hallenbeck-2013-effec-o2">[hallenbeck-2013-effec-o2]</a> <a name="hallenbeck-2013-effec-o2">Hallenbeck & Kitchin, Effects of O2 and So2 on the Capture Capacity of a  Primary-Amine Based Polymeric Co2 Sorbent, <i>Industrial & Engineering Chemistry Research</i>, <b>52(31)</b>, 10788-10794 (2013). <a href="http://dx.doi.org/10.1021/ie400582a">link</a>. <a href="http://dx.doi.org/10.1021/ie400582a">doi</a>.</li>
<li><a id="miller-2014-simul-temper">[miller-2014-simul-temper]</a> <a name="miller-2014-simul-temper">Spencer Miller, Vladimir Pushkarev, Andrew, Gellman & John Kitchin, Simulating Temperature Programmed Desorption of Oxygen on  Pt(111) Using DFT Derived Coverage Dependent Desorption  Barriers, <i>Topics in Catalysis</i>, <b>57(1-4)</b>, 106-117 (2014). <a href="http://dx.doi.org/10.1007/s11244-013-0166-3">link</a>. <a href="http://dx.doi.org/10.1007/s11244-013-0166-3">doi</a>.</li>
<li><a id="curnan-2014-effec-concen">[curnan-2014-effec-concen]</a> <a name="curnan-2014-effec-concen">Curnan & Kitchin, Effects of Concentration, Crystal Structure, Magnetism, and  Electronic Structure Method on First-Principles Oxygen Vacancy  Formation Energy Trends in Perovskites, <i>The Journal of Physical Chemistry C</i>, <b>118(49)</b>, 28776-28790 (2014). <a href="http://dx.doi.org/10.1021/jp507957n">link</a>. <a href="http://dx.doi.org/10.1021/jp507957n">doi</a>.</li>
<li><a id="xu-2014-probin-cover">[xu-2014-probin-cover]</a> <a name="xu-2014-probin-cover">Zhongnan Xu & John Kitchin, Probing the Coverage Dependence of Site and Adsorbate  Configurational Correlations on (111) Surfaces of Late  Transition Metals, <i>J. Phys. Chem. C</i>, <b>118(44)</b>, 25597-25602 (2014). <a href="http://dx.doi.org/10.1021/jp508805h">link</a>. <a href="http://dx.doi.org/10.1021/jp508805h">doi</a>.</li>
<li><a id="xu-2014-relat">[xu-2014-relat]</a> <a name="xu-2014-relat">Zhongnan Xu & John Kitchin, Relating the Electronic Structure and Reactivity of the 3d  Transition Metal Monoxide Surfaces, <i>Catalysis Communications</i>, <b>52</b>, 60-64 (2014). <a href="http://dx.doi.org/10.1016/j.catcom.2013.10.028">link</a>. <a href="http://dx.doi.org/10.1016/j.catcom.2013.10.028">doi</a>.</li>
<li><a id="mehta-2015-ident-poten">[mehta-2015-ident-poten]</a> <a name="mehta-2015-ident-poten">Prateek Mehta, Paul Salvador & John Kitchin, Identifying Potential \ceBO2 Oxide Polymorphs for Epitaxial  Growth Candidates, <i>ACS Appl. Mater. Interfaces</i>, <b>6(5)</b>, 3630-3639 (2015). <a href="http://dx.doi.org/10.1021/am4059149">link</a>. <a href="http://dx.doi.org/10.1021/am4059149">doi</a>.</li>
<li><a id="boes-2015-estim-bulk">[boes-2015-estim-bulk]</a> <a name="boes-2015-estim-bulk">Jacob Boes, Gamze Gumuslu, James Miller, Andrew, Gellman & John Kitchin, Estimating Bulk-Composition-Dependent \ceH2 Adsorption  Energies on \ceCu_xPd_1-x Alloy (111) Surfaces, <i>ACS Catalysis</i>, <b>5(2)</b>, 1020-1026 (2015). <a href="http://dx.doi.org/10.1021/cs501585k">link</a>. <a href="http://dx.doi.org/10.1021/cs501585k">doi</a>.</li>
<li><a id="boes-2015-estim-bulk-si">[boes-2015-estim-bulk-si]</a> <a name="boes-2015-estim-bulk-si">Jacob Boes, Gamze Gumuslu, James Miller, Andrew, Gellman & John Kitchin, Supporting Information: Estimating Bulk-Composition-Dependent  \ceH2 Adsorption Energies on \ceCu_xPd_1-x Alloy (111)  Surfaces, <i>ACS Catalysis</i>, <b>5</b>, 1020-1026 (2015). <a href="http://pubs.acs.org/doi/suppl/10.1021/cs501585k/suppl_file/cs501585k_si_001.pdf">link</a>. <a href="http://dx.doi.org/10.1021/cs501585k">doi</a>.</li>
<li><a id="kitchin-2015-examp">[kitchin-2015-examp]</a> <a name="kitchin-2015-examp">Kitchin, Examples of Effective Data Sharing in Scientific Publishing, <i>ACS Catalysis</i>, <b>5(6)</b>, 3894-3899 (2015). <a href=" http://dx.doi.org/10.1021/acscatal.5b00538 ">link</a>. <a href="http://dx.doi.org/10.1021/acscatal.5b00538">doi</a>.</li>
<li><a id="kitchin-2015-data-surfac-scien">[kitchin-2015-data-surfac-scien]</a> <a name="kitchin-2015-data-surfac-scien">"John Kitchin", Data Sharing in Surface Science, <i>"Surface Science "</i>, <b>647</b>, 103-107 (2016). <a href="http://www.sciencedirect.com/science/article/pii/S0039602815001326">link</a>. <a href="http://dx.doi.org/10.1016/j.susc.2015.05.007">doi</a>.</li>
<li><a id="xu-2015-accur-u">[xu-2015-accur-u]</a> <a name="xu-2015-accur-u">"Xu, Joshi, Raman, & Kitchin, Accurate Electronic and Chemical Properties of 3d Transition  Metal Oxides Using a Calculated Linear Response U and a DFT  + U(V) Method, <i>"The Journal of Chemical Physics"</i>, <b>142(14)</b>, 144701 (2015). <a href="http://scitation.aip.org/content/aip/journal/jcp/142/14/10.1063/1.4916823">link</a>. <a href="http://dx.doi.org/10.1063/1.4916823">doi</a>.</li>
<li><a id="xu-2015-linear-respon">[xu-2015-linear-respon]</a> <a name="xu-2015-linear-respon">Xu, Rossmeisl & Kitchin, A Linear Response DFT+U Study of Trends in the Oxygen  Evolution Activity of Transition Metal Rutile Dioxides, <i>The Journal of Physical Chemistry C</i>, <b>119(9)</b>, 4827-4833 (2015). <a href=" http://dx.doi.org/10.1021/jp511426q ">link</a>. <a href="http://dx.doi.org/10.1021/jp511426q">doi</a>.</li>
<li><a id="xu-2015-relat">[xu-2015-relat]</a> <a name="xu-2015-relat">Zhongnan Xu & John Kitchin, Relationships Between the Surface Electronic and Chemical  Properties of Doped 4d and 5d Late Transition Metal Dioxides, <i>The Journal of Chemical Physics</i>, <b>142(10)</b>, 104703 (2015). <a href="http://dx.doi.org/10.1063/1.4914093">link</a>. <a href="http://dx.doi.org/10.1063/1.4914093">doi</a>.</li>
<li><a id="xu-2015-tunin-oxide">[xu-2015-tunin-oxide]</a> <a name="xu-2015-tunin-oxide">Zhongnan Xu & John R Kitchin, Tuning Oxide Activity Through Modification of the Crystal and  Electronic Structure: From Strain To Potential Polymorphs, <i>Phys. Chem. Chem. Phys.</i>, <b>17</b>, 28943-28949 (2015). <a href="http://dx.doi.org/10.1039/C5CP04840K">link</a>. <a href="http://dx.doi.org/10.1039/c5cp04840k">doi</a>.</li>
<li><a id="boes-2017-model-segreg">[boes-2017-model-segreg]</a> <a name="boes-2017-model-segreg">Boes & Kitchin, Modeling Segregation on AuPd(111) Surfaces With Density  Functional Theory and Monte Carlo Simulations, <i>The Journal of Physical Chemistry C</i>, <b>121(6)</b>, 3479-3487 (2017). <a href="https://doi.org/10.1021/acs.jpcc.6b12752">link</a>. <a href="http://dx.doi.org/10.1021/acs.jpcc.6b12752">doi</a>.</li>
<li><a id="boes-2017-neural-networ">[boes-2017-neural-networ]</a> <a name="boes-2017-neural-networ">Jacob Boes & John Kitchin, Neural Network Predictions of Oxygen Interactions on a Dynamic  Pd Surface, <i>Molecular Simulation</i>, <b></b>, 1-9 (2017). <a href="https://doi.org/10.1080/08927022.2016.1274984">link</a>. <a href="http://dx.doi.org/10.1080/08927022.2016.1274984">doi</a>.</li>
<li><a id="geng-2017-first-princ">[geng-2017-first-princ]</a> <a name="geng-2017-first-princ">Feiyang Geng, Jacob Boes & John Kitchin, First-Principles Study of the Cu-Pd Phase Diagram, <i>Calphad</i>, <b>56</b>, 224-229 (2017). <a href="https://doi.org/10.1016/j.calphad.2017.01.009">link</a>. <a href="http://dx.doi.org/10.1016/j.calphad.2017.01.009">doi</a>.</li>
<li><a id="xu-2017-first-princ">[xu-2017-first-princ]</a> <a name="xu-2017-first-princ">Xu, Salvador & Kitchin, First-Principles Investigation of the Epitaxial Stabilization  of Oxide Polymorphs: \ceTiO2 on \ce(Sr,Ba)TiO3, <i>ACS Applied Materials & Interfaces</i>, <b>9(4)</b>, 4106-4118 (2017). <a href="https://doi.org/10.1021/acsami.6b11791">link</a>. <a href="http://dx.doi.org/10.1021/acsami.6b11791">doi</a>.</li>
<li><a id="kitchin-2017-autom-data">[kitchin-2017-autom-data]</a> <a name="kitchin-2017-autom-data">"Kitchin, Van Gulick & Zilinski, Automating Data Sharing Through Authoring Tools, <i>"International Journal on Digital Libraries"</i>, <b>18(2)</b>, 93-98 (2017). <a href="https://doi.org/10.1007/s00799-016-0173-7">link</a>. <a href="http://dx.doi.org/10.1007/s00799-016-0173-7">doi</a>.</li>
<li><a id="wang-2018-densit-funct">[wang-2018-densit-funct]</a> <a name="wang-2018-densit-funct">Chen Wang, Akshay Tharval & John Kitchin, A Density Functional Theory Parameterised Neural Network Model  of Zirconia, <i>Molecular Simulation</i>, <b>nil(nil)</b>, 1-8 (2018). <a href="https://doi.org/10.1080/08927022.2017.1420185">link</a>. <a href="http://dx.doi.org/10.1080/08927022.2017.1420185">doi</a>.</li>
<li><a id="gao-2018-model-pallad">[gao-2018-model-pallad]</a> <a name="gao-2018-model-pallad">Tianyu Gao & John Kitchin, Modeling Palladium Surfaces With Density Functional Theory,  Neural Networks and Molecular Dynamics, <i>Catalysis Today</i>, <b>nil(nil)</b>, nil (2018). <a href="https://doi.org/10.1016/j.cattod.2018.03.045">link</a>. <a href="http://dx.doi.org/10.1016/j.cattod.2018.03.045">doi</a>.</li>
<li><a id="thirumalai-2018-inves-react">[thirumalai-2018-inves-react]</a> <a name="thirumalai-2018-inves-react">Hari Thirumalai & John Kitchin, Investigating the Reactivity of Single Atom Alloys Using  Density Functional Theory, <i>Topics in Catalysis</i>, <b>nil(nil)</b>, nil (2018). <a href="https://doi.org/10.1007/s11244-018-0899-0">link</a>. <a href="http://dx.doi.org/10.1007/s11244-018-0899-0">doi</a>.</li>
<li><a id="kitchin-2018-machin-learn-catal">[kitchin-2018-machin-learn-catal]</a> <a name="kitchin-2018-machin-learn-catal">John Kitchin, Machine Learning in Catalysis, <i>Nature Catalysis</i>, <b>1(4)</b>, 230-232 (2018). <a href="https://doi.org/10.1038/s41929-018-0056-y">link</a>. <a href="http://dx.doi.org/10.1038/s41929-018-0056-y">doi</a>.</li>
</ul>
</p>
</div>
</div>
