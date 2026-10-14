My Photos:
<table>
% for photo in photos:
  <tr><td><a href="${photo}.html">
    <img src="${photo}" height="175"></a></td><td>${photo}</td></tr>
% endfor
</table>