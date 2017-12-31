<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgd665c9c">1. Machine learned atomistic potentials</a></li>
<li><a href="#org4c607ae">2. Data sharing and functional scientific documents</a></li>
<li><a href="#org62462e1">3. Alloy catalysis</a></li>
<li><a href="#org4dca3cb">4. Metal oxide reactivity</a></li>
<li><a href="#org6cb83c7">5. Past research topics</a>
<ul>
<li><a href="#org0ed04f0">5.1. CO<sub>2</sub> Capture</a></li>
<li><a href="#org078e0cf">5.2. Oxygen evolution electrocatalysis</a></li>
<li><a href="#org80a558b">5.3. Coverage dependent adsorption</a></li>
</ul>
</li>
</ul>
</div>
</div>
<%inherit file="_templates/site.mako" />

<p>
We describe here the main research areas the Kitchin Group has been active in. For each area we briefly describe what we have done, with reference to most of the publications that resulted from the work.
</p>

<p>
For a complete listing of our publications see <a href="./publications.html">./publications.html</a>.
</p>


<div id="outline-container-orgd665c9c" class="outline-2">
<h2 id="orgd665c9c"><span class="section-number-2">1</span> Machine learned atomistic potentials</h2>
<div class="outline-text-2" id="text-1">
<p>
Molecular simulation continues to drive scientific progress. In all simulations, one of the main challenges is how to get good computational models to describe the chemistry and physics of the system. For decades we have relied on physical insight to build these models, but even these often have computationally practical approximations. A new approach using models derived by machine learning has developed in the past decade. In this approach, we use large databases of calculations from density functional theory to build neural network models of atomistic systems.
</p>

<p>
You can see our work in these papers.
</p>

<dl class="org-dl">
<dt><a class='org-ref-reference' href="#boes-2016-neural-networ">boes-2016-neural-networ</a></dt><dd>A comparison of a neural network potential with ReaxFF for gold</dd>
<dt><a class='org-ref-reference' href="#boes-2017-neural-networ">boes-2017-neural-networ</a></dt><dd>Using a neural network potential to model coverage dependent adsorption</dd>
<dt><a class='org-ref-reference' href="#boes-2017-model-segreg">boes-2017-model-segreg</a></dt><dd>Using a neural network potential to model segregation in an alloy</dd>
</dl>

<p>
This is an exciting new area we will be publishing in for the next few years!
</p>
</div>
</div>


<div id="outline-container-org4c607ae" class="outline-2">
<h2 id="org4c607ae"><span class="section-number-2">2</span> Data sharing and functional scientific documents</h2>
<div class="outline-text-2" id="text-2">
<p>
We are huge proponents of using org-mode to write scientific documents. This has enabled our group to develop novel data sharing strategies <a class='org-ref-reference' href="#kitchin-2015-examp">kitchin-2015-examp</a>,<a class='org-ref-reference' href="#kitchin-2015-data-surfac-scien">kitchin-2015-data-surfac-scien</a> and increase our productivity significantly. 
</p>

<p>
We recently published this work on automated data sharing <a class='org-ref-reference' href="#kitchin-2017-autom-data">kitchin-2017-autom-data</a>.
</p>
</div>
</div>

<div id="outline-container-org62462e1" class="outline-2">
<h2 id="org62462e1"><span class="section-number-2">3</span> Alloy catalysis</h2>
<div class="outline-text-2" id="text-3">
<p>
Alloy catalysts frequently do not have the same reactivity as the parent metals. We use density functional theory calculations to understand how the electronic structure of the alloy differs from the parent metals, and how those differences lead to different reactivities. We are especially interested in modeling heterogeneous site distributions <a class='org-ref-reference' href="#boes-2015-estim-bulk">boes-2015-estim-bulk</a>, modeling XPS spectra of alloys <a class='org-ref-reference' href="#boes-2015-core-cu">boes-2015-core-cu</a>, and the limit of single atom alloys <a class='org-ref-reference' href="#tierney-2009-hydrog-dissoc">tierney-2009-hydrog-dissoc</a>. 
</p>

<p>
We have used density functional theory to identify S-tolerant alloys <a class='org-ref-reference' href="#inoglu-2011-ident-sulfur">inoglu-2011-ident-sulfur</a>. Our current work will develop a new understanding of selectivity in acetylene hydrogenation.
</p>

<p>
PhD Jacob Boes: <a class='org-ref-reference' href="#boes-2017-multis-model">boes-2017-multis-model</a>
</p>
</div>
</div>

<div id="outline-container-org4dca3cb" class="outline-2">
<h2 id="org4dca3cb"><span class="section-number-2">4</span> Metal oxide reactivity</h2>
<div class="outline-text-2" id="text-4">
<p>
We are generally interested in understanding the reactivity of metal oxides towards oxygen and fuels. We use computational tools to model the electronic structure and reactivity of metal oxides for applications in water splitting and chemical looping.
</p>

<p>
We derived a number of heuristic rules that describe the reactivity of perovskites <a class='org-ref-reference' href="#akhade-2011-effec">akhade-2011-effec</a>,<a class='org-ref-reference' href="#akhade-2012-effec">akhade-2012-effec</a>. These principles were expanded into a concept of outer electrons that was used to describe the reactivity of a broad range of oxides <a class='org-ref-reference' href="#calle-vallejo-2013-number">calle-vallejo-2013-number</a>. These observations have been found to be robust across a broad range of assumptions in the models used, although some care must be taken in a few cases <a class='org-ref-reference' href="#curnan-2014-effec-concen">curnan-2014-effec-concen</a>. We have found novel relationships between oxide electronic structure and reactivity for oxides with rocksalt structures <a class='org-ref-reference' href="#xu-2014-relat">xu-2014-relat</a>.
</p>

<p>
We did some work in infiltrating solid oxide fuel cell electrodes with
electrocatalysts to improve their activity
<a class='org-ref-reference' href="#chao-2011-prepar-mesop">chao-2011-prepar-mesop</a>,<a class='org-ref-reference' href="#chao-2012-struc-relat">chao-2012-struc-relat</a>.
</p>

<p>
An outstanding challenge in modeling oxides is the highly correlated electrons especially in the 3d orbitals of transition metals. We have expanded an approach to use a linear response method to compute U, making a nearly predictive, first-principles method for computing oxide formation energies with pretty good accuracy <a class='org-ref-reference' href="#xu-2015-accur-u">xu-2015-accur-u</a>.
</p>

<p>
One new direction we have taken is to identify oxide polymorphs that may be grown as epitaxial thin films <a class='org-ref-reference' href="#mehta-2015-ident-poten">mehta-2015-ident-poten</a>. Subsequent work <a class='org-ref-reference' href="#xu-2017-first-princ">xu-2017-first-princ</a> has shown some design principles for predicting epitaxial stabilization, including the successful synthesis of columbite SnO<sub>2</sub> <a class='org-ref-reference' href="#wittkamper-2017-compet-growt">wittkamper-2017-compet-growt</a>.
</p>

<p>
PhD Robin Chao: <a class='org-ref-reference' href="#chao-2012-improv-solid">chao-2012-improv-solid</a> 
</p>
</div>
</div>




<div id="outline-container-org6cb83c7" class="outline-2">
<h2 id="org6cb83c7"><span class="section-number-2">5</span> Past research topics</h2>
<div class="outline-text-2" id="text-5">
<p>
We have worked in these research areas in the past, but are not currently actively working on them.
</p>
</div>

<div id="outline-container-org0ed04f0" class="outline-3">
<h3 id="org0ed04f0"><span class="section-number-3">5.1</span> CO<sub>2</sub> Capture</h3>
<div class="outline-text-3" id="text-5-1">
<p>
CO<sub>2</sub> capture remains an important tool in considering how to mitigate the role of fossil energy on climate change <a class='org-ref-reference' href="#rubin-2012">rubin-2012</a>. We have investigated the use of supported amines <a class='org-ref-reference' href="#alesi-2010-co2-adsor">alesi-2010-co2-adsor</a>, and a commercially available ion exchange resin as a CO<sub>2</sub> capture sorbent <a class='org-ref-reference' href="#alesi-2012-evaluat-primar">alesi-2012-evaluat-primar</a>. We have shown that supported amines are poisoned by SO<sub>2</sub>, but may they may be partially regenerated in some cases <a class='org-ref-reference' href="#hallenbeck-2013-effec-o2">hallenbeck-2013-effec-o2</a>. 
</p>


<p>
We have used density functional theory calculations to model amine-CO<sub>2</sub> reactions <a class='org-ref-reference' href="#lee-2012-chemic-molec">lee-2012-chemic-molec</a>,<a class='org-ref-reference' href="#mao-2013-inter">mao-2013-inter</a>, as well as process modeling to show that different process conditions are required to optimize a capture process for different solvents <a class='org-ref-reference' href="#lee-2013-compar-co2">lee-2013-compar-co2</a>. We have considered ionic liquids as potential CO<sub>2</sub> capture solvents <a class='org-ref-reference' href="#thompson-2014-co2-react">thompson-2014-co2-react</a>.
</p>

<p>
We also have developed a high pressure silica capillary cell for in situ Raman measurements of CO<sub>2</sub> solubility in solvents for precombustion capture applications. Our current interests include developing a microfluidic device for measuring CO<sub>2</sub> absorption rates in amine-based solvents. We collaborate with the <a href="http://annalab.org/">the Anna group</a> on this.
</p>

<p>
We previously explored the electrochemical separation of CO<sub>2</sub> from flue gas <a class='org-ref-reference' href="#landon-2010-elect-concen">landon-2010-elect-concen</a>,<a class='org-ref-reference' href="#pennline-2010-separ-co2">pennline-2010-separ-co2</a>.
</p>


<p>
PhD Anita Lee: <a class='org-ref-reference' href="#lee-2013-multi-scale">lee-2013-multi-scale</a>
</p>

<p>
PhD Rich Alesi: <a class='org-ref-reference' href="#walesi-2012-amine-based-sorben">walesi-2012-amine-based-sorben</a>
</p>
</div>
</div>

<div id="outline-container-org078e0cf" class="outline-3">
<h3 id="org078e0cf"><span class="section-number-3">5.2</span> Oxygen evolution electrocatalysis</h3>
<div class="outline-text-3" id="text-5-2">
<p>
We are using Raman spectroscopy to probe the oxide/electrolyte interface under oxygen evolution conditions. We have focused most of our work on Ni-oxide containing materials, which are highly active when promoted by Fe impurities <a class='org-ref-reference' href="#landon-2012-spect-charac">landon-2012-spect-charac</a>,<a class='org-ref-reference' href="#michael-2015-alkal-elect">michael-2015-alkal-elect</a>. We have also examined Fe-containing molecular electrocatalysts
 <a class='org-ref-reference' href="#demeter-2014-elect-oxygen">demeter-2014-elect-oxygen</a>.
</p>

<p>
We have used density functional theory to show that there are correlations in the reactions of the oxygen evolution reaction that likely limit the activity of oxide-based electrocatalysts <a class='org-ref-reference' href="#man-2011-univer-oxygen">man-2011-univer-oxygen</a>. These observations are robust, even with advanced computational methods such as the linear response DFT+U methods <a class='org-ref-reference' href="#xu-2015-linear-respon">xu-2015-linear-respon</a>.
</p>

<p>
PhD James Landon: <a class='org-ref-reference' href="#landon-2011-elect-oxygen-produc">landon-2011-elect-oxygen-produc</a>
</p>

<p>
PhD Ethan Demeter: <a class='org-ref-reference' href="#demeter-2013-promot-base">demeter-2013-promot-base</a>
</p>
</div>
</div>

<div id="outline-container-org80a558b" class="outline-3">
<h3 id="org80a558b"><span class="section-number-3">5.3</span> Coverage dependent adsorption</h3>
<div class="outline-text-3" id="text-5-3">
<p>
Our earliest work was in modeling the coverage dependent adsorption energies of atomic adsorbates on late transition metal surfaces. We showed that there exist strong configurational correlations for many adsorbates on Pd(111) <a class='org-ref-reference' href="#kitchin-2009-correl-pd">kitchin-2009-correl-pd</a>, and for oxygen on late transition metal surfaces <a class='org-ref-reference' href="#miller-2009-relat-au">miller-2009-relat-au</a>,<a class='org-ref-reference' href="#miller-2011-config">miller-2011-config</a>. These principles were generalized in a simple physical model <a class='org-ref-reference' href="#inoglu-2010-simpl">inoglu-2010-simpl</a> that showed the origin of the coverage dependence was an adsorbate-induced modification of the surface electronic structure. We wrote a review book chapter on this topic <a class='org-ref-reference' href="#miller-2012-cover">miller-2012-cover</a>. We demonstrated that DFT can be used to interpret the coverage dependent desorption behavior of oxygen on Pt(111) <a class='org-ref-reference' href="#miller-2014-simul-temper">miller-2014-simul-temper</a>.  Finally, we showed the generality of configurational correlations across many surfaces and for many adsorbates, demonstrating that geometric similarity is a requirement for correlation <a class='org-ref-reference' href="#xu-2014-probin-cover">xu-2014-probin-cover</a>.
</p>

<p>
PhD Spencer Miller: <a class='org-ref-reference' href="#miller-2011-towar-under">miller-2011-towar-under</a>
</p>

<p>
PhD Nilay Inoglu: <a class='org-ref-reference' href="#inoglu-2012-desig-sulfur">inoglu-2012-desig-sulfur</a>
</p>

<p>
<h1 class='org-ref-bib-h1'>Bibliography</h1>
<ul class='org-ref-bib'><li><a id="boes-2016-neural-networ">[boes-2016-neural-networ] Jacob Boes, Mitchell Groenenboom, John Keith, & John Kitchin, Neural Network and Reaxff Comparison for Au Properties, <i>Int. J. Quantum Chem.</i>, <b>116(13)</b>, 979-987 (2016). <a href="http://dx.doi.org/10.1002/qua.25115">link</a>. <a href="http://dx.doi.org/10.1002/qua.25115">doi</a>.</a></li>
<li><a id="boes-2017-neural-networ">[boes-2017-neural-networ] Jacob Boes & John Kitchin, Neural Network Predictions of Oxygen Interactions on a Dynamic  Pd Surface, <i>Molecular Simulation</i>, <b></b>, 1-9 (2017). <a href="https://doi.org/10.1080/08927022.2016.1274984">link</a>. <a href="http://dx.doi.org/10.1080/08927022.2016.1274984">doi</a>.</a></li>
<li><a id="boes-2017-model-segreg">[boes-2017-model-segreg] Boes & Kitchin, Modeling Segregation on AuPd(111) Surfaces With Density  Functional Theory and Monte Carlo Simulations, <i>The Journal of Physical Chemistry C</i>, <b>121(6)</b>, 3479-3487 (2017). <a href="https://doi.org/10.1021/acs.jpcc.6b12752">link</a>. <a href="http://dx.doi.org/10.1021/acs.jpcc.6b12752">doi</a>.</a></li>
<li><a id="kitchin-2015-examp">[kitchin-2015-examp] Kitchin, Examples of Effective Data Sharing in Scientific Publishing, <i>ACS Catalysis</i>, <b>5(6)</b>, 3894-3899 (2015). <a href=" http://dx.doi.org/10.1021/acscatal.5b00538 ">link</a>. <a href="http://dx.doi.org/10.1021/acscatal.5b00538">doi</a>.</a></li>
<li><a id="kitchin-2015-data-surfac-scien">[kitchin-2015-data-surfac-scien] "John Kitchin", Data Sharing in Surface Science, <i>"Surface Science "</i>, <b>647</b>, 103-107 (2016). <a href="http://www.sciencedirect.com/science/article/pii/S0039602815001326">link</a>. <a href="http://dx.doi.org/10.1016/j.susc.2015.05.007">doi</a>.</a></li>
<li><a id="kitchin-2017-autom-data">[kitchin-2017-autom-data] "Kitchin, Van Gulick & Zilinski, Automating Data Sharing Through Authoring Tools, <i>"International Journal on Digital Libraries"</i>, <b>18(2)</b>, 93-98 (2017). <a href="https://doi.org/10.1007/s00799-016-0173-7">link</a>. <a href="http://dx.doi.org/10.1007/s00799-016-0173-7">doi</a>.</a></li>
<li><a id="boes-2015-estim-bulk">[boes-2015-estim-bulk] Jacob Boes, Gamze Gumuslu, James Miller, Andrew, Gellman & John Kitchin, Estimating Bulk-Composition-Dependent \ceH2 Adsorption  Energies on \ceCu_xPd_1-x Alloy (111) Surfaces, <i>ACS Catalysis</i>, <b>5(2)</b>, 1020-1026 (2015). <a href="http://dx.doi.org/10.1021/cs501585k">link</a>. <a href="http://dx.doi.org/10.1021/cs501585k">doi</a>.</a></li>
<li><a id="boes-2015-core-cu">[boes-2015-core-cu] Jacob Boes, Peter Kondratyuk, Chunrong Yin, James, Miller, Andrew Gellman & John Kitchin, Core Level Shifts in Cu-Pd Alloys As a Function of Bulk  Composition and Structure, <i>Surface Science</i>, <b>640</b>, 127-132 (2015). <a href="http://dx.doi.orgpr/10.1016/j.susc.2015.02.011">link</a>. <a href="http://dx.doi.org/10.1016/j.susc.2015.02.011">doi</a>.</a></li>
<li><a id="tierney-2009-hydrog-dissoc">[tierney-2009-hydrog-dissoc] Tierney, Baber, Kitchin, Sykes & , Hydrogen Dissociation and Spillover on Individual Isolated  Palladium Atoms, <i>Physical Review Letters</i>, <b>103(24)</b>, 246102 (2009). <a href="http://prl.aps.org/abstract/PRL/v103/i24/e246102">link</a>. <a href="http://dx.doi.org/10.1103/PhysRevLett.103.246102">doi</a>.</a></li>
<li><a id="inoglu-2011-ident-sulfur">[inoglu-2011-ident-sulfur] Inoglu & Kitchin, Identification of Sulfur-Tolerant Bimetallic Surfaces Using  DFT Parametrized Models and Atomistic Thermodynamics, <i>ACS Catalysis</i>, <b></b>, 399-407 (2011). <a href="http://dx.doi.org/10.1021/cs200039t">doi</a>.</a></li>
<li><a id="boes-2017-multis-model">[boes-2017-multis-model] @PhdThesisboes-2017-multis-model,
  author =	 Jacob Russell Boes,
  school =	 Carnegie Mellon University,
  title =	 Multiscale Modeling of Adsorbate Interactions on Transition
                  Metal Alloy Surfaces,
  url =		 http://repository.cmu.edu/dissertations/875/,
  year =	 2017,
</a></li>
<li><a id="akhade-2011-effec">[akhade-2011-effec] Akhade & Kitchin, Effects of Strain, d-Band Filling, and Oxidation State on the  Bulk Electronic Structure of Cubic 3d Perovskites, <i>The Journal of Chemical Physics</i>, <b>135(10)</b>, 104702-6 (2011). <a href="http://dx.doi.org/10.1063/1.3631948">link</a>.</a></li>
<li><a id="akhade-2012-effec">[akhade-2012-effec] Akhade & Kitchin, Effects of Strain, d-Band Filling, and Oxidation State on the  Surface Electronic Structure and Reactivity of 3d Perovskite  Surfaces , <i>J. Chem. Phys.</i>, <b>137</b>, 084703 (2012). <a href="http://scitation.aip.org/content/aip/journal/jcp/137/8/10.1063/1.4746117">link</a>. <a href="http://dx.doi.org/10.1063/1.4746117">doi</a>.</a></li>
<li><a id="calle-vallejo-2013-number">[calle-vallejo-2013-number] Calle-Vallejo, Inoglu, Su, , Martinez, Man, Koper, , Kitchin & Rossmeisl, Number of Outer Electrons As Descriptor for Adsorption  Processes on Transition Metals and Their Oxides, <i>Chemical Science</i>, <b>4</b>, 1245-1249 (2013). <a href="http://dx.doi.org/10.1039/C2SC21601A">link</a>. <a href="http://dx.doi.org/10.1039/C2SC21601A">doi</a>.</a></li>
<li><a id="curnan-2014-effec-concen">[curnan-2014-effec-concen] Curnan & Kitchin, Effects of Concentration, Crystal Structure, Magnetism, and  Electronic Structure Method on First-Principles Oxygen Vacancy  Formation Energy Trends in Perovskites, <i>The Journal of Physical Chemistry C</i>, <b>118(49)</b>, 28776-28790 (2014). <a href="http://dx.doi.org/10.1021/jp507957n">link</a>. <a href="http://dx.doi.org/10.1021/jp507957n">doi</a>.</a></li>
<li><a id="xu-2014-relat">[xu-2014-relat] Zhongnan Xu & John Kitchin, Relating the Electronic Structure and Reactivity of the 3d  Transition Metal Monoxide Surfaces, <i>Catalysis Communications</i>, <b>52</b>, 60-64 (2014). <a href="http://dx.doi.org/10.1016/j.catcom.2013.10.028">link</a>. <a href="http://dx.doi.org/10.1016/j.catcom.2013.10.028">doi</a>.</a></li>
<li><a id="chao-2011-prepar-mesop">[chao-2011-prepar-mesop] Chao, Kitchin, Gerdes, Sabolsky, Edward & Salvador, Preparation of Mesoporous \ceLa_0.8Sr_0.2MnO3  Infiltrated Coatings in Porous SOFC Cathodes Using  Evaporation-Induced Self-Assembly Methods, <i>ECS Transactions</i>, <b>35(1)</b>, 2387-2399 (2011). <a href="http://ecst.ecsdl.org/content/35/1/2387.abstract">link</a>. <a href="http://dx.doi.org/10.1149/1.3570235">doi</a>.</a></li>
<li><a id="chao-2012-struc-relat">[chao-2012-struc-relat] Chao, Munprom, Petrova, , Gerdes, Kitchin & Salvador, Structure and Relative Thermal Stability of Mesoporous  (La,Sr)MnO$_3$ Powders Prepared Using  Evaporation-Induced Self-Assembly Methods, <i>Journal of the American Ceramic Society</i>, <b></b>, 2339-2346 (2012). <a href="http://dx.doi.org/10.1111/j.1551-2916.2012.05236.x">link</a>. <a href="http://dx.doi.org/10.1111/j.1551-2916.2012.05236.x">doi</a>.</a></li>
<li><a id="xu-2015-accur-u">[xu-2015-accur-u] "Xu, Joshi, Raman, & Kitchin, Accurate Electronic and Chemical Properties of 3d Transition  Metal Oxides Using a Calculated Linear Response U and a DFT  + U(V) Method, <i>"The Journal of Chemical Physics"</i>, <b>142(14)</b>, 144701 (2015). <a href="http://scitation.aip.org/content/aip/journal/jcp/142/14/10.1063/1.4916823">link</a>. <a href="http://dx.doi.org/10.1063/1.4916823">doi</a>.</a></li>
<li><a id="mehta-2015-ident-poten">[mehta-2015-ident-poten] Prateek Mehta, Paul Salvador & John Kitchin, Identifying Potential \ceBO2 Oxide Polymorphs for Epitaxial  Growth Candidates, <i>ACS Appl. Mater. Interfaces</i>, <b>6(5)</b>, 3630-3639 (2015). <a href="http://dx.doi.org/10.1021/am4059149">link</a>. <a href="http://dx.doi.org/10.1021/am4059149">doi</a>.</a></li>
<li><a id="xu-2017-first-princ">[xu-2017-first-princ] Xu, Salvador & Kitchin, First-Principles Investigation of the Epitaxial Stabilization  of Oxide Polymorphs: \ceTiO2 on \ce(Sr,Ba)TiO3, <i>ACS Applied Materials & Interfaces</i>, <b>9(4)</b>, 4106-4118 (2017). <a href="https://doi.org/10.1021/acsami.6b11791">link</a>. <a href="http://dx.doi.org/10.1021/acsami.6b11791">doi</a>.</a></li>
<li><a id="wittkamper-2017-compet-growt">[wittkamper-2017-compet-growt] Julia Wittkamper, Zhongnan Xu, Boopathy Kombaiah, , Farangis Ram, Marc De Graef, John Kitchin, Gregory, Rohrer & Paul Salvador, Competitive Growth of Scrutinyite ($\alpha$-\cePbO2) and Rutile  Polymorphs of \ceSnO2 on All Orientations of Columbite Conb2o6  Substrates, <i>Crystal Growth & Design</i>, <b>17(7)</b>, 3929-3939 (2017). <a href="https://doi.org/10.1021/acs.cgd.7b00569">link</a>. <a href="http://dx.doi.org/10.1021/acs.cgd.7b00569">doi</a>.</a></li>
<li><a id="chao-2012-improv-solid">[chao-2012-improv-solid] @phdthesischao-2012-improv-solid,
  Author =	 Robin Chao,
  Title =	 Improving Solid Oxide Fuel Cell Cathode Performance by Infiltrating Mesoporous Perovskite Coatings,
  School =	 Carnegie Mellon University,
  Year =	 2012</a></li>
<li><a id="rubin-2012">[rubin-2012] Rubin, Mantripragada, Marks, , Versteeg & Kitchin, The Outlook for Improved Carbon Capture Technology, <i>Progress in Energy and Combustion Science</i>, <b>38</b>, 630-671 (2012). <a href="http://www.sciencedirect.com/science/article/pii/S0360128512000184">link</a>. <a href="http://dx.doi.org/10.1016/j.pecs.2012.03.003">doi</a>.</a></li>
<li><a id="alesi-2010-co2-adsor">[alesi-2010-co2-adsor] Richard Alesi, McMahan Gray & John Kitchin, \ceCO2 Adsorption on Supported Molecular Amidine Systems on  Activated Carbon, <i>ChemSusChem</i>, <b>3(8)</b>, 948-956 (2010). <a href="http://dx.doi.org/10.1002/cssc.201000056">link</a>. <a href="http://dx.doi.org/10.1002/cssc.201000056">doi</a>.</a></li>
<li><a id="alesi-2012-evaluat-primar">[alesi-2012-evaluat-primar] Alesi & Kitchin, Evaluation of a Primary Amine-Functionalized Ion-Exchange  Resin for \ceCO_2 Capture, <i>Industrial & Engineering Chemistry Research</i>, <b>51(19)</b>, 6907-6915 (2012). <a href="http://dx.doi.org/10.1021/ie300452c">link</a>. <a href="http://dx.doi.org/10.1021/ie300452c">doi</a>.</a></li>
<li><a id="hallenbeck-2013-effec-o2">[hallenbeck-2013-effec-o2] Hallenbeck & Kitchin, Effects of O2 and So2 on the Capture Capacity of a  Primary-Amine Based Polymeric Co2 Sorbent, <i>Industrial & Engineering Chemistry Research</i>, <b>52(31)</b>, 10788-10794 (2013). <a href="http://dx.doi.org/10.1021/ie400582a">link</a>. <a href="http://dx.doi.org/10.1021/ie400582a">doi</a>.</a></li>
<li><a id="lee-2012-chemic-molec">[lee-2012-chemic-molec] Lee & Kitchin, Chemical and Molecular Descriptors for the Reactivity of  Amines With \ceCO_2, <i>Industrial & Engineering Chemistry Research</i>, <b>51(42)</b>, 13609-13618 (2012). <a href="http://pubs.acs.org/doi/abs/10.1021/ie301419q">link</a>. <a href="http://dx.doi.org/10.1021/ie301419q">doi</a>.</a></li>
<li><a id="mao-2013-inter">[mao-2013-inter] Mao, Lee, Kitchin, , Nulwala, Luebke, Damodaran & Krishnan, Interactions in 1-ethyl-3-methyl Imidazolium Tetracyanoborate  Ion Pair: Spectroscopic and Density Functional Study, <i>Journal of Molecular Structure</i>, <b>1038(0)</b>, 12-18 (2013). <a href="http://www.sciencedirect.com/science/article/pii/S0022286013000707">link</a>. <a href="http://dx.doi.org/10.1016/j.molstruc.2013.01.046">doi</a>.</a></li>
<li><a id="lee-2013-compar-co2">[lee-2013-compar-co2] Anita Lee, John Eslick, David Miller, John & Kitchin, Comparisons of Amine Solvents for Post-Combustion \ceCO2  Capture: A Multi-Objective Analysis Approach, <i>International Journal of Greenhouse Gas Control</i>, <b>18</b>, 68-74 (2013). <a href="http://dx.doi.org/10.1016/j.ijggc.2013.06.020">link</a>. <a href="http://dx.doi.org/10.1016/j.ijggc.2013.06.020">doi</a>.</a></li>
<li><a id="thompson-2014-co2-react">[thompson-2014-co2-react] Thompson, Albenze, Shi, , Hopkinson, Damodaran, Lee, , Kitchin, Luebke & Nulwala, \ceCO2 Reactive Ionic Liquids: Effects of Functional  Groups on the Anion and Its Influence on the Physical  Properties, <i>RSC Adv.</i>, <b>4</b>, 12748-12755 (2014). <a href="http://dx.doi.org/10.1039/C3RA47097K">link</a>. <a href="http://dx.doi.org/10.1039/C3RA47097K">doi</a>.</a></li>
<li><a id="landon-2010-elect-concen">[landon-2010-elect-concen] Landon & Kitchin, Electrochemical Concentration of Carbon Dioxide From an  Oxygen/carbon Dioxide Containing Gas Stream, <i>Journal of the Electrochemical Society</i>, <b>157(8)</b>, B1149-B1153 (2010). <a href="http://jes.ecsdl.org/content/157/8/B1149">link</a>. <a href="http://dx.doi.org/10.1149/1.3432440">doi</a>.</a></li>
<li><a id="pennline-2010-separ-co2">[pennline-2010-separ-co2] Henry Pennline, Evan Granite, David Luebke, , John Kitchin, James Landon & Lisa Weiland, Separation of \ceCO2 From Flue Gas Using Electrochemical  Cells, <i>Fuel</i>, <b>89(6)</b>, 1307-1314 (2010). <a href="http://dx.doi.org/10.1016/j.fuel.2009.11.036">link</a>. <a href="http://dx.doi.org/10.1016/j.fuel.2009.11.036">doi</a>.</a></li>
<li><a id="lee-2013-multi-scale">[lee-2013-multi-scale] @PhdThesislee-2013-multi-scale,
  author =	 Anita Lee,
  title =	 A Multi-Scale Approach to Understanding CO2-Solvent Systems for the Development of CO2 Capture Technologies,
  school =	 Carnegie Mellon University,
  year =	 2013,
  note =	 http://repository.cmu.edu/dissertations/237/</a></li>
<li><a id="walesi-2012-amine-based-sorben">[walesi-2012-amine-based-sorben] @phdthesiswalesi-2012-amine-based-sorben,
  Author =	 W. Richard Alesi, Jr.,
  Title =	 Amine Based Sorbents : Developing a Quantitative Framework for
                  Understanding CO2 Capture,
  School =	 Carnegie Mellon University,
  Year =	 2012
</a></li>
<li><a id="landon-2012-spect-charac">[landon-2012-spect-charac] James Landon, Ethan Demeter, Nilay Ino\uglu, , Chris Keturakis, Israel Wachs, Relja Vasi\'c, , Anatoly Frenkel & John Kitchin, Spectroscopic Characterization of Mixed Fe-Ni Oxide  Electrocatalysts for the Oxygen Evolution Reaction in Alkaline  Electrolytes, <i>ACS Catalysis</i>, <b>2(8)</b>, 1793-1801 (2012). <a href="http://dx.doi.org/10.1021/cs3002644">link</a>. <a href="http://dx.doi.org/10.1021/cs3002644">doi</a>.</a></li>
<li><a id="michael-2015-alkal-elect">[michael-2015-alkal-elect] John Michael, Ethan Demeter, Steven Illes, , Qingqi Fan, Jacob Boes & John Kitchin, Alkaline Electrolyte and Fe Impurity Effects on the  Performance and Active-Phase Structure of NiOOH Thin Films  for OER Catalysis Applications, <i>J. Phys. Chem. C</i>, <b>119(21)</b>, 11475-11481 (2015). <a href="http://dx.doi.org/10.1021/acs.jpcc.5b02458">link</a>. <a href="http://dx.doi.org/10.1021/acs.jpcc.5b02458">doi</a>.</a></li>
<li><a id="demeter-2014-elect-oxygen">[demeter-2014-elect-oxygen] Ethan Demeter, Shayna Hilburg, Newell Washburn, , Terrence Collins & John Kitchin, Electrocatalytic Oxygen Evolution With an Immobilized TAML  Activator, <i>J. Am. Chem. Soc.</i>, <b>136(15)</b>, 5603-5606 (2014). <a href="http://dx.doi.org/10.1021/ja5015986">link</a>. <a href="http://dx.doi.org/10.1021/ja5015986">doi</a>.</a></li>
<li><a id="man-2011-univer-oxygen">[man-2011-univer-oxygen] Man, Su, Calle-Vallejo, Hansen, , Martinez, Inoglu, Kitchin, , Jaramillo, N\orskov, Rossmeisl & , Universality in Oxygen Evolution Electrocatalysis on Oxide  Surfaces, <i>ChemCatChem</i>, <b>3(7)</b>, 1159-1165 (2011). <a href="http://dx.doi.org/10.1002/cctc.201000397">doi</a>.</a></li>
<li><a id="xu-2015-linear-respon">[xu-2015-linear-respon] Xu, Rossmeisl & Kitchin, A Linear Response DFT+U Study of Trends in the Oxygen  Evolution Activity of Transition Metal Rutile Dioxides, <i>The Journal of Physical Chemistry C</i>, <b>119(9)</b>, 4827-4833 (2015). <a href=" http://dx.doi.org/10.1021/jp511426q ">link</a>. <a href="http://dx.doi.org/10.1021/jp511426q">doi</a>.</a></li>
<li><a id="landon-2011-elect-oxygen-produc">[landon-2011-elect-oxygen-produc] @phdthesislandon-2011-elect-oxygen-produc,
  Author =	 James Landon,
  Title =	 Electrochemical Oxygen Production: Catalyst Development to Meet the World's Oxygen Demands,
  School =	 Carnegie Mellon University,
  Year =	 2011</a></li>
<li><a id="demeter-2013-promot-base">[demeter-2013-promot-base] @PhdThesisdemeter-2013-promot-base,
  author =	 Ethan Demeter,
  title =	 The Promotion of Base Metal Catalysts for the Electrochemical Oxygen Evolution Reaction,
  school =	 Carnegie Mellon University,
  year =	 2013,
  note =	 http://repository.cmu.edu/dissertations/236/</a></li>
<li><a id="kitchin-2009-correl-pd">[kitchin-2009-correl-pd] Kitchin, Correlations in Coverage-Dependent Atomic Adsorption Energies  on Pd(111), <i>Physical Review B</i>, <b>79(20)</b>, 205412 (2009). <a href="http://dx.doi.org/10.1103/PhysRevB.79.205412">doi</a>.</a></li>
<li><a id="miller-2009-relat-au">[miller-2009-relat-au] Miller & Kitchin, Relating the Coverage Dependence of Oxygen Adsorption on Au  and Pt Fcc(111) Surfaces Through Adsorbate-Induced Surface  Electronic Structure Effects, <i>Surface Science</i>, <b>603(5)</b>, 794-801 (2009). <a href="http://dx.doi.org/10.1016/j.susc.2009.01.021">doi</a>.</a></li>
<li><a id="miller-2011-config">[miller-2011-config] Spencer Miller, Nilay Inoglu & John Kitchin, Configurational Correlations in the Coverage Dependent  Adsorption Energies of Oxygen Atoms on Late Transition Metal  fcc(111) Surfaces, <i>J. Chem. Phys.</i>, <b>134(10)</b>, 104709 (2011). <a href="http://dx.doi.org/10.1063/1.3561287">link</a>. <a href="http://dx.doi.org/10.1063/1.3561287">doi</a>.</a></li>
<li><a id="inoglu-2010-simpl">[inoglu-2010-simpl] Inoglu & Kitchin, Simple Model Explaining and Predicting Coverage-Dependent  Atomic Adsorption Energies on Transition Metal Surfaces, <i>Physical Review B</i>, <b>82(4)</b>, 045414 (2010). <a href="http://dx.doi.org/10.1103/PhysRevB.82.045414">link</a>. <a href="http://dx.doi.org/10.1103/PhysRevB.82.045414">doi</a>.</a></li>
<li><a id="miller-2012-cover">[miller-2012-cover] @inbookmiller-2012-cover,
  Author =	 Spencer Miller and Carmeline Dsilva and John R. Kitchin,
  Title =	 Coverage dependent adsorption properties of atomic adsorbates
                  on late transition metal surfaces,
  Keywords =	 DEFG0207ER15919,
  Booktitle =	 Catalysis,
  Series =	 Catalysis,
  Publisher =	 Royal Society of Chemistry (RSC),
  Year =	 2012,
  Pages =	 83-115,
  Doi =		 10.1039/9781849734776-00083,
  Url =		 http://dx.doi.org/10.1039/9781849734776-00083,
</a></li>
<li><a id="miller-2014-simul-temper">[miller-2014-simul-temper] Spencer Miller, Vladimir Pushkarev, Andrew, Gellman & John Kitchin, Simulating Temperature Programmed Desorption of Oxygen on  Pt(111) Using DFT Derived Coverage Dependent Desorption  Barriers, <i>Topics in Catalysis</i>, <b>57(1-4)</b>, 106-117 (2014). <a href="http://dx.doi.org/10.1007/s11244-013-0166-3">link</a>. <a href="http://dx.doi.org/10.1007/s11244-013-0166-3">doi</a>.</a></li>
<li><a id="xu-2014-probin-cover">[xu-2014-probin-cover] Zhongnan Xu & John Kitchin, Probing the Coverage Dependence of Site and Adsorbate  Configurational Correlations on (111) Surfaces of Late  Transition Metals, <i>J. Phys. Chem. C</i>, <b>118(44)</b>, 25597-25602 (2014). <a href="http://dx.doi.org/10.1021/jp508805h">link</a>. <a href="http://dx.doi.org/10.1021/jp508805h">doi</a>.</a></li>
<li><a id="miller-2011-towar-under">[miller-2011-towar-under] @phdthesismiller-2011-towar-under,
  Author =	 Spencer Miller,
  Title =	 Towards an Understanding of Coverage Dependent Atomic
                  Adsorption on Late Transition Metals,
  School =	 Carnegie Mellon University,
  Year =	 2011
</a></li>
<li><a id="inoglu-2012-desig-sulfur">[inoglu-2012-desig-sulfur] @PhdThesisinoglu-2012-desig-sulfur,
  author =	 Nilay Inoglu,
  title =	 Design of Sulfur Tolerant Transition Metal Catalysts and Oxide Based Oxygen Evolution Electrocatalysts,
  school =	 Carnegie Mellon University,
  year =	 2012</a></li>
</ul>
</p>
</div>
</div>
</div>
