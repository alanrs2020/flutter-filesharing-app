import 'package:flutter/cupertino.dart';

class home {
  getHome(files){
    String htmlData = '''<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<link rel="icon" type="image/icon" href="logo">
	<title>Bytes File Sharing & PDF Scanner</title>
</head>
<style type="text/css">
*{
 	font-family: sans-serif;
 }
body{
	background-color: #ddd;
}
	.headerTab{
	width: 400px;
	margin: auto;
	display: flex;
	border-radius: 30px;
	padding:5px 5px;
	justify-content: space-around;
	flex-direction: row;
	height: 60px;
	background: #333;	
	}
	.headerTab div{
		padding: 20px 10px;
		color: #ddd;
		border-radius: 20px;
		background: #333;
	}
	.headerTab div:hover{
		cursor: pointer;
		background-color: #fff;
		color: #222;
	}
	.bodyTab{
		width: 100%;
		height: 100%;
		
	}
	#gallery{
	background-color: #fff;
	color: #333;
	}
	.image-box{
		display: flex;
		padding: 10px;
		flex-direction: column;
		
	}
	#image{
		display: flex;
		padding: 10px 10px;
		margin: 20px;
		justify-content: space-around;
		flex-direction: row;
		flex-wrap: wrap;
	}
	.image{
		width: 150px;
		height: 150px;
		object-fit: cover;
	}
	.linkButton{

		padding: 10px 15px;
		background-color: #333;
		color: red;
		text-decoration: none;
	}
	.linkButton:hover{
		background-color: #222;
	}
	#loadMore{
		padding: 10px 20px;
		background-color: #333;
		color: #ddd;
		margin: auto;
		outline: none;
		border: none;
	}
	#loadMore:hover{
		background-color: #fff;
		color: #333;
	}
	#loading{
	  position: absolute;
	  display: none;
	  z-index: 100;
	  width:100%;
	  font-size: 5em;
	  color: cyan;
	  height:100vh;
	  background-color: #333;
	}
</style>
<body >
<div id="loading">
<center>Please wait...</center>
</div>
<div class="headerTab">
	<div id="gallery">Gallery</div>
	<div id="baudio">Audio</div>
	<div id="bvideo">Movie</div>
<!-- <div id="bdocument">Document</div> -->

</div>
<div class="bodyTab">
	<div id="image">
	

	</div>
</div>
<div>
	<button id="loadMore">Load More</button>
</div>
</body>
<script type="text/javascript">


// function loaded(){
// document.getElementById('loading').style.display = "none";
// }
//imagebody

var b1 = document.getElementById('image');


var num = 20;
var startNum = 0;
var imageList = [];
imageList = $files;
loadData(20);
function loadData(sizeOfLength){
num = sizeOfLength;
for(var i=startNum;i<sizeOfLength;i++){

var name = imageList[i];
var d1 = document.createElement('div');
var d2 = document.createElement('div');
var d3 = document.createElement('div');

var imageBox = document.createElement('div');
var img = document.createElement('img');
var para = document.createElement('p');
var link = document.createElement('a');
	img.src = imageList[i];
	img.className = "image";
	para.innerHTML = name.split("/").at(-1);
	link.href = imageList[i];
	link.setAttribute('download','');
	link.innerHTML = "Download";
	link.className = "linkButton";
	imageBox.className = "image-box";

	d1.appendChild(img);
	d2.appendChild(para);
	d3.appendChild(link);

	imageBox.appendChild(d1);
	imageBox.appendChild(d2);
	imageBox.appendChild(d3);
	b1.appendChild(imageBox);

}
}
var loadMore = document.getElementById('loadMore');

	loadMore.addEventListener('click',event=>{
		if (num+20 <= imageList.length) {
		startNum = startNum + 20;
			loadData(num +20);
			console.log(num);
		}else{
		  startNum = imageList.length - startNum;
		  loadMore(imageList.length);
			loadMore.style.display = "none";
		}
	});
	//tabbody
	
	var b2 = document.getElementById('audio');
	var b3 = document.getElementById('video');
	var b4 = document.getElementById('document');
	

	//buttons
	var bn1 = document.getElementById('gallery');
	var bn2 = document.getElementById('baudio');
	var bn3 = document.getElementById('bvideo');
	var bn4 = document.getElementById('bdocument');

	 bn1.addEventListener('click',event=>{
          window.location.href = "/";
          });
          bn2.addEventListener('click',event=>{
          window.location.href = "/audio";
          });
          bn3.addEventListener('click',event=>{
          window.location.href = "/video";
          });
          bn4.addEventListener('click',event=>{
          window.location.href = "/document";
          });




</script>
</html>''';

    return htmlData;
  }


}