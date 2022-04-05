Class Cubes.UI.Search Extends %CSP.Page
{

ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	&html<
	
	<!DOCTYPE html>
	<html lang="ken">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width" />
		<title>Cube Search</title>
		<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto">
		<style>

		html,body,p,ol,ul,li,dl,dt,dd,blockquote,figure,fieldset,legend,textarea,pre,iframe,hr,h1,h2,h3,h4,h5,h6 {margin:0;padding:0}h1,h2,h3,h4,h5,h6 {font-size:100%; font-weight:normal;}
		ul {list-style:none;}
		button,input,select {margin:0;}
		html{box-sizing:border-box;}
		*, *::before, *::after {box-sizing:inherit;}
		img,video {height:auto;max-width:100%;}
		iframe {border:0;}
		table {border-collapse:collapse;border-spacing:0;}
		td,th {padding:0;}

		body {font-family: 'Roboto', serif; padding: 2em;}
		h1 { font-size: 1.5em; }
		h2 { font-size: 1.25em; }
		h3 { font-size: 1.1em; }
		hr { margin-bottom: 1em; }

		.pad1 { padding: 1.2em; }
		.pad2 { padding: 1em; }
		.pad3 { padding: 0.8em; }
		.pad4 { padding: 0.6em; }
		.pad5 { padding: 0.4em; }
		.padtop { padding: 0.5em; }
		.center { text-align: center; }
		.right { text-align: right; padding-right: 1em; }
		.search { width: 400px; }
		.results { font-size: 0.8em;}
		.results table { width: 2000px; }
		.blue { color: #05B8CC; }
		.lineno { color: #5B59BA; font-style: italic; width: 5em; padding-right: 1em;}
		</style>
	</head>
	<body>

	<div>
		<div class="">
			<h1>Cube Search</h1>
			<br>
			<input class="search" id="searchText" type="search" autocomplete="off" spellcheck="false" placeholder="Enter Search Word(s)" value="Dictionary">		
			<br>
			<br>
			<input id="searchButton" type="button" value="Search" />
			<br>
			<br>
			<div id="resultsContainer" class="results"></div>
		<div>
	</div>
	
	<script language="JavaScript">
	(function () {
		var searchText=document.getElementById("searchText");
		var searchButton=document.getElementById("searchButton");
		var resultsContainer=document.getElementById("resultsContainer");
		searchButton.addEventListener("click", function(ev) {
			var start = new Date().getTime();
			fetch('http://localhost:52773/cubes/codesys/object?$query=' + searchText.value.replace(/[,\/#!$%\^&\;:{}=\_`~()]/g," "))
			.then(function(res){return res.json()})
			.then(function(data){
				var last='';
				var html=data.map( function(item) {
					var name = item[3];
					if (name === last) name="";
					last = item[3];
					var code=escapeHTML(item[5]);
					searchText.value.replace(/[,\/#!$%\^&\;:{}=\_`~()]/g," ").split(" ").map( function(word) {
						word=escapeHTML(word);
						if (word === "") return;
						if (code.indexOf(word) > -1) {
							code = code.replace(word,'<b>' + word + '</b>');
						}
					});
					return '<tr><td colspan=2 class="blue pad4">'+name+'</td></tr><tr><td class="right lineno">'+item[4]+'</td><td>'+code+'</td></tr>'
				}).join('');
				var end = new Date().getTime();
				var time = end - start; 
				resultsContainer.innerHTML='<span>'+data.length+' results in '+ time +'ms</span><br><br><table>' + html + '</table>';	
			})	
		})
		function escapeHTML(unsafe) {
		  return unsafe.replace(
		    /[\u0000-\u002F\u003A-\u0040\u005B-\u0060\u007B-\u00FF]/g,
		    c => '&#' + ('000' + c.charCodeAt(0)).slice(-4) + ';'
		  )
		}
	})();
	</script>
	
	</body>
	</html>
	
	>
	Quit $$$OK
}

}
