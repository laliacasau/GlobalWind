<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
// Mind that some headers are not included because they're either useless or unreliable. X-Secondlife-Local-Position 
// apache headers
$headers    = apache_request_headers();
$objectgrid = $headers["X-SecondLife-Shard"];
$objectname = $headers["X-SecondLife-Object-Name"];
$objectkey  = $headers["X-SecondLife-Object-Key"];
$objectpos  = $headers["X-SecondLife-Local-Position"];
$ownerkey   = $headers["X-SecondLife-Owner-Key"];
$ownername  = $headers["X-SecondLife-Owner-Name"];
$regiondata = $headers["X-SecondLife-Region"];
$regiontmp  = explode ("(",$regiondata);        // cut cords off
$regionpos  = explode (")",$regiontmp[1]);
$regionpos  = explode (",",$regionpos[0]);
$regionname = substr($regiontmp[0],0,-1);       // cut last space from simname

$data       = file_get_contents("php://input");
$groups     = explode("##",$data);  //gen data, var areas, var circles
$cols       = explode(",",$groups[0]);

require '../../glwdb.php';

    $reqNum=(integer)$cols[0];
    $reqTot=(integer)$cols[1];
    $reqSims=(integer)$cols[2];
    if($reqNum>1) $file=$cols[3];
    else $file="";
    $coordSW_x=(integer)$cols[4];
    $coordSW_y=(integer)$cols[5];
    $coordNE_x=(integer)$cols[6];
    $coordNE_y=(integer)$cols[7];
    $offsetWest=(integer)$cols[8];
    $offsetNorth=(integer)$cols[9];
    $offsetEast=(integer)$cols[10];
    $offsetSouth=(integer)$cols[11];
    if($reqNum==1){
        $swMap=(integer)$cols[12];
    }
    
    $coordSW_x-=$offsetWest;
    $coordSW_y-=$offsetSouth;
    $coordNE_x+=$offsetWest;
    $coordNE_y+=$offsetNorth;

    $dist_x=abs($coordNE_x-$coordSW_x)+1;
    $dist_y=abs($coordNE_y-$coordSW_y)+1;
    if($dist_x>=$dist_y){ 
        $simSize=(integer)(1024/$dist_x);
    }else{ 
        $simSize=(integer)(1024/$dist_y);
    }
    $size_x=$dist_x*$simSize;
    $size_y=$dist_y*$simSize;
   
    //echo "$coordSW_x  $coordSW_y  $coordNE_x  $coordNE_y  $simSize\n ";
    
    if($reqNum==1){
        $image = imagecreatetruecolor($size_x, $size_y)
            or die("Cannot Initialize image stream");
        if($swMap==1){
            $white = imagecolorallocate($image, 255, 255, 255);
            imagefill($image, 0, 0, $white);
            $file="Map_".(string)(time()%86400).".jpg";
        }else{
            imagealphablending($image, false);
            imagesavealpha($image, true);
            //$color = imagecolorallocatealpha($image,0x00,0x00,0x00,127); 
            $color = imagecolorallocatealpha($image,0,0,0,127); 
            imagefill($image, 0, 0, $color);
            $file="Map_".(string)(time()%86400).".png";
            //imagepng($image,"../map/".$file,0, PNG_NO_FILTER);
            imagepng($image,"../map/".$file);
            imagedestroy($image);
            echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file";
            return;
        }
    }else{
        $image=imagecreatefromjpeg("../map/".$file);
    }
        
    $simTot=$dist_x*$dist_y;
    if($simTot>1000) die("Only 1000 sims can be represented");
    
    $simStart=($reqNum-1)*$reqSims;
    $simEnd=$simStart+$reqSims-1;
    if($simEnd>=$simTot) $simEnd=$simTot-1;
    $simStart_x=$simStart%$dist_x;
    $simEnd_x=$dist_x-1;
    $simStart_y=(integer)($simStart/$dist_x);
    $simEnd_y=(integer)($simEnd/$dist_x);
    $x=0;
    $y=0;
    for($i=$simStart;$i<=$simEnd;$i++){
        $x=$i%$dist_x;
        $y=(integer)($i/$dist_x);
        addSim($coordSW_x+$x,$coordSW_y+$y,$x,$dist_y-$y-1,$simSize);
    }
    
    
    /*
    for($y=$simStart_y;$y<=$simEnd_y;$y++){
        for($x=$simStart_x;$x<=$simEnd_x;$x++){
            addSim($coordSW_x+$x,$coordSW_y+$y,$x,$dist_y-$y-1,$simSize);
        }
    }
    */
    
    imagejpeg($image,"../map/".$file,100);
    imagedestroy($image);
    echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file";
    //echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file"."    $simStart   $simEnd";

    //echo "\ndist: $dist_x  $dist_y  $size_x   $size_y  $simSize";
    //echo "\n$simStart   $simEnd   $simStart_x   $simEnd_x   $simStart_y   $simEnd_y";
    
    
function addSim($pCoorX,$pCoorY,$pPosX,$pPosY,$pSimSize)
{
    global $image;
    $urlMap="http://map.secondlife.com/map-1-$pCoorX-$pCoorY-objects.jpg";
    $im=imagecreatefromjpeg($urlMap);
    if(!$im){
        $im = imagecreatetruecolor($pSimSize, $pSimSize);
        $SeaColor = imagecolorallocate($im, 29, 71, 95);
        imagefill($im, 0, 0, $SeaColor);        
        imagecopy($image, $im, $pPosX*$pSimSize, $pPosY*$pSimSize, 0, 0, $pSimSize, $pSimSize);
    }else{
        imagecopyresized($image, $im, $pPosX*$pSimSize, $pPosY*$pSimSize, 0, 0, $pSimSize, $pSimSize, 256, 256); 
    }
    imagedestroy($im);
}
    

/*
//create reg map
$sql = "INSERT INTO glwMaps (coordSW_x,coordSW_y,coordNE_x,coordNE_y)
    VALUES ('$cols[0]','$cols[1]','$cols[2]','$cols[3]')";
if ($conn->query($sql) === TRUE) {
    $idMaps = $conn->insert_id;

    $coordSW_x=(integer)$cols(0);
    $coordSW_y=(integer)$cols(1);
    $coordNE_x=(integer)$cols(2);
    $coordNE_y=(integer)$cols(3);
    
    $urlMap="http://map.secondlife.com/map-1-$coordSW_x-$coordSW_y-objects.jpg";
    print "map: "+$urlMap;
*/    
    /*
    //save Areas Vars
    if($groups[1]!=""){
        $vars = explode("$$",$groups[1]);
        $nt=sizeof($vars);
        for($i=0;$i<$nt;$i++){
            //echo $vars[$i];
            $parts=explode(":",$vars[$i]);    
            $cols=explode(",",$parts[0]);   //active,sim1,corner1x,corner1y,sim2,corner2x,corner2y,margin 
            $parts0=str_replace("'","''",$parts[0]);
            //coords are sim coords values
            $sql = "INSERT INTO glwMapVariations (idEvents,type,coord1X,coord1Y,coord2X,coord2Y,margin,overlap,itemData,windData) 
                VALUES ($idMaps,1,$cols[2]/256,$cols[3]/256,$cols[5]/256,$cols[6]/256,$cols[7],$cols[8],'$parts0','$parts[1])";
            if ($conn->query($sql) === TRUE) {
            }else print "Error1: " . $sql . "<br>" . $conn->error;
        }
    }

    //save Circles Vars
    if($groups[2]!=""){
        $vars = explode("$$",$groups[2]);
        $nt=sizeof($vars);
        for($i=0;$i<$nt;$i++){
            $parts=explode(":",$vars[$i]);    
            $cols=explode(",",$parts[0]);  //active,sim1,global1x,global1y,sim2,global2x,global2y,radius,margin
            $simX=(integer)($cols[2]/256); //coord sim x
            $localX=$cols[2]-($simX*256);  //local pos x
            $simY=(integer)($cols[3]/256);  //coord sim y
            $localY=$cols[3]-($simY*256);  //local pos y
            $radius=$cols[7];
            $margin=$cols[8];
            $overlap=$cols[9];
            if($margin>$radius-5) $margin=$radius-5;
            $parts0=str_replace("'","''",$parts[0]);
            
            $sql = "INSERT INTO glwMapVariations (idEvents,type,coord1X,coord1Y,coord2X,coord2Y,radius,margin,overlap,itemData,windData) 
                VALUES ($idMaps,2,$simX,$simY,$localX,$localY,$radius,$margin,$overlap,'$parts0','$parts[1]')";
            if ($conn->query($sql) === TRUE) {
            }else print "Error2: " . $sql . "<br>" . $conn->error;
        }
    }
}
    */
    
?>


























