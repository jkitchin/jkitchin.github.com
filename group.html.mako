<%inherit file="_templates/site.mako" />
<article class="page_box">
<%self:filter chain="markdown">

Group meeting schedule

<%include file="group-meetings-2015.md"/>
</%self:filter>
</article>
