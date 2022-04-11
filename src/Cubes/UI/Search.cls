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
		<link rel=stylesheet href=https://cdn.jsdelivr.net/npm/pretty-print-json@1.2/dist/pretty-print-json.css>
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

		a:link { color: hsl(200, 25%, 40%) }
		a:visited { color: hsl(200, 25%, 60%) }
		a:active { color: hsl(200, 25%, 80%) }
		a:hover { color: hsl(200, 25%, 80%) }

		.pad1 { padding: 1.2em; }
		.pad2 { padding: 1em; }
		.pad2:empty { padding: 0em; }
		.pad3 { padding: 0.8em; }
		.pad4 { padding: 0.6em; }
		.pad5 { padding: 0.4em; }
		.max800 { max-width: 899px; }
		.padtop { padding: 0.5em; }
		.center { text-align: center; }
		.right { text-align: right; padding-right: 1em; }
		.search { width: 400px; }
		.results { font-size: 0.8em;}
		.results table { width: 2000px; }
		.lineno { color: #5B59BA; font-style: italic; width: 5em; padding-right: 1em;}
		.courier { font-family: 'Courier New' }
		.bggrey { background-color: #f8f8f8; }
		.hide { display: none; }
		
		</style>
	</head>
	<body>

	<div>
		<div class="">
			<h1>Cube Search</h1>
			<br>
			Cube: <select id="cubeName">
			>
			set sys=$o(^Cubes(""))
			while sys'="" {
				write !,"<option value='"_sys_"' data-size='"_$g(^CubesD(^Cubes(sys)))_"'>"_sys_"</option>"
				set sys=$o(^Cubes(sys))
			}
			&html<
			</select>
			<br>
			<br>
			<input class="search" id="searchText" type="search" autocomplete="off" spellcheck="false" placeholder="Enter Search Word(s)" value="">		
			<br>
			<br>
			<input id="searchButton" type="button" value="Search" />
			<br>
			<br>
			<div id="resultsContainer" class="results"></div>
		<div>
	</div>
	
	<script src=https://cdn.jsdelivr.net/npm/pretty-print-json@1.2/dist/pretty-print-json.min.js></script>
	<script language="JavaScript">
	(function () {
		
		var cubeSelect=document.getElementById("cubeName")
		var searchText=document.getElementById("searchText");
		var searchButton=document.getElementById("searchButton");
		var resultsContainer=document.getElementById("resultsContainer");
		
		searchButton.addEventListener("click", queryServerCube )
		
		searchText.addEventListener("keyup", function (ev) {
      		if (event.keyCode === 13) {
         		queryServerCube(ev)
      		}	
   		})
		
		resultsContainer.addEventListener("click", function(ev) {
			if (!ev.srcElement.href) return;
			if (ev.srcElement.parentElement.children[1].children[0].textContent !== '') {
				ev.srcElement.parentElement.children[1].classList.toggle('hide');
				ev.srcElement.parentElement.children[1].children[0].textContent = '';
				return	
			}
     		if (ev.srcElement.href) {
	         	fetch('http://localhost:52773' + ev.srcElement.dataset.href)
				.then(function(res){return res.text()})
				.then(function(text){
					searchText.value.replace(/[,\/#!$%\^&\;:{}=\_`~()*]/g," ").split(" ").map( function(word) {
						if (word === "") return;
						word=escapeHTML(word);
						if (text.indexOf(word) > -1) {
							text = text.replaceAll(word,'<b>' + word + '</b>');
						}
					});
					ev.srcElement.parentElement.children[1].classList.toggle('hide');
					ev.srcElement.parentElement.children[1].children[0].textContent  = text;
				})
     		}
		});
		
		function queryServerCube(ev) {
			var cubeName=cubeSelect.value;
			var cubeSize=cubeSelect.selectedOptions[0].getAttribute('data-size');
			var start = new Date().getTime();
			fetch('http://localhost:52773/cubes/'+cubeName+'/object?$query=' + searchText.value.replace(/[,\/#!$%\^&\;:{}=\_`~()]/g," "))
			.then(function(res){return res.json()})
			.then(function(data){
				var last='';
				var html=data.map( function(item) {
					var tag = item.tag;
					if (tag === last) tag="";
					last = item.tag;
					var text=escapeHTML(item.text);
					searchText.value.replace(/[,\/#!$%\^&\;:{}=\_`~()]/g," ").split(" ").map( function(word) {
						if (word === "") return;
						word=escapeHTML(word);
						if (text.indexOf(word) > -1) {
							text = text.replaceAll(word,'<b>' + word + '</b>');
						}
					});
					return '<tr><td colspan=2 class="blue pad4" id="'+item.oid+'">' +
					       ' <a href="#dummy" data-href="/cubes/'+cubeName+'/object/'+item.oid+'">'+tag+'</a>' + 
					       ' <div class="pad2 hide"><pre class="courier bggrey pad2"></pre></div>' +
					       ' </td></tr>' +
					       '<tr><td class="right lineno">'+item.line+'</td><td><div class="max800 courier">'+text+'</div></td></tr>'
				}).join('');
				var end = new Date().getTime();
				var time = end - start; 
				resultsContainer.innerHTML='<span>'+data.length+' results from '+cubeSize+' objects in '+ time +'ms</span><br><br><table>' + html + '</table>';
			})	
		}
		
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
