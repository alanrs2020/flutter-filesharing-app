class video{
  getVideos(files){
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
    margin: 0;
    padding: 0;
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
    #bvideo{
    background-color: #fff;
    color: #222;
    }
        .bodyTab{
    width: 100%;
    height: 100%;

    }
        .image-box{
    display: flex;
    padding: 15px;
		margin: 10px;
    background-color: #333;
    flex-direction: column;

    }
    #main-body{
    display: flex;
    padding: 10px 10px;
    margin: 20px;
    justify-content: space-around;
    flex-direction: row;
    flex-wrap: wrap;
    }
        .image{
    width: 450px;
    height: 250px;
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
    }p{
    color: #ddd;
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
    </style>
    <body>
    <div class="headerTab">
    <div id="gallery">Gallery</div>
    <div id="baudio">Audio</div>
    <div id="bvideo">Movie</div>
  <!-- <div id="bdocument">Document</div> -->

    </div>
    <div class="bodyTab">
    <div id="main-body">


    </div>
    </div>
    <div>
	<button id="loadMore">Load More</button>
</div>
    </body>
    <script type="text/javascript">

//imagebody


    var videoList = $files; 
    var num = 10;
    var startNum = 0;
    
    var b1 = document.getElementById('main-body');
    
    loadData(10)
    function loadData(size){
    num = size;
    for(var i=startNum;i<size;i++){
    
    var name = videoList[i]; 
    var d1 = document.createElement('div');

    var d2 = document.createElement('div');

    var d3 = document.createElement('div');

    var imageBox = document.createElement('div');
//videotags
    var img = document.createElement('video');
    img.setAttribute('controls','');
//img.setAttribute('type','video/mp4');
//source
    var path = document.createElement('source');
    path.src = videoList[i];
    img.appendChild(path);

//name
    var para = document.createElement('p');
    var link = document.createElement('a');

    img.className = "image";
    para.innerHTML = name.split("/").at(-1);
    link.href = videoList[i];
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
		if (num+10 <= videoList.length) {
		startNum = startNum + 10;
			loadData(num +10);
			console.log(num);
		}else{
		  startNum = videoList.length - startNum;
		  loadMore(videoList.length);
			loadMore.style.display = "none";
		}
	});
    //tabbody





    //buttons
    var bn1 = document.getElementById('gallery');
    var bn2 = document.getElementById('baudio');
    var bn3 = document.getElementById('bvideo');
    var bn4 = document.getElementById('bdocument');

    bn1.addEventListener('click',event=>{
    window.location.href = "/";
    });
    bn2.addEventListener('click',event=>{
    window.location.href = "audio";
    });
    bn3.addEventListener('click',event=>{
    window.location.href = "video";
    });
    bn4.addEventListener('click',event=>{
    window.location.href = "document";
    });




    </script>
    </html>''';

    return htmlData;
  }
}