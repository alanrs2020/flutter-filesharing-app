class audio{
  getAudio(List files){
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
          background-color: #222;
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
          #baudio{
          background-color: #fff;
          color: #222;
          }
              .bodyTab{
          width: 100%;
          height: 100%;

          }
          .audio-box{
          display: flex;
          padding: 10px;
          width: 500px;
          height: 150px;
          flex-direction: row;

          }
          #main-body{
          display: flex;
          padding: 10px 10px;
          margin: 20px;
          justify-content: space-around;
          flex-direction: row;
          flex-wrap: wrap;
          }
          .audio-logo{
          background-color: #ddd;
          width: 150px;
          }
              .audio-voice{
          width: 300px;
          padding: 10px;
          background-color: #ddd;
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


          var b1 = document.getElementById('main-body');

     
           
           var num = 10;
           var startNum = 0;
           var audioList = [];
audioList = $files;
           loadData(10);
           
          function loadData(sizeOfLength){
           num = sizeOfLength
          for(var i=startNum;i<sizeOfLength;i++){
          
            var name = audioList[i];
            var audioBox = document.createElement('div');

            audioBox.className = "audio-box";


            var d1 = document.createElement('div');

            d1.className = "audio-logo";

            var d2 = document.createElement('div');
            d2.className = "audio-voice";

            //var d3 = document.createElement('div');

            var img = document.createElement('img');
            img.src = '/audioLogo';
            img.className = "image";
            var music = document.createElement('audio');

            music.setAttribute('controls',"");

            var path = document.createElement('source');

            path.src = String(audioList[i]);

            var para = document.createElement('p');
            para.innerHTML = "Song Id: "+name;
            var link = document.createElement('a');


            link.href = String(audioList[i]);
            link.setAttribute('download','');
            link.innerHTML = "Download";
            link.className = "linkButton";


            d1.appendChild(img);
            music.appendChild(path);
            d2.appendChild(music);
            d2.appendChild(para);
            d2.appendChild(link);

            audioBox.appendChild(d1);
            audioBox.appendChild(d2);

            b1.appendChild(audioBox);

          }
          }

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
          window.location.href = "/audio";
          });
          bn3.addEventListener('click',event=>{
          window.location.href = "/video";
          });
          bn4.addEventListener('click',event=>{
          window.location.href = "/document";
          });

var loadMore = document.getElementById('loadMore');

	loadMore.addEventListener('click',event=>{
		if (num+10 <=audioList.length) {
			startNum = startNum +10;
			loadData(num +10);
			console.log(num);
		}else{
		startNum = audioList.length - startNum;
		  loadMore(audioList.length);
			loadMore.style.display = "none";
		}
	});
        </script>
        </html>''';

    return htmlData;
  }
}