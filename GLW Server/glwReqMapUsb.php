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
    $swMap=(integer)$cols[12];    
    
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
    
    if($swMap==1){
        $image=imagecreatefromjpeg("../map/".$file);
    }else{
        $image=imagecreatefrompng("../map/".$file);
        imagealphablending($image, false);
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
    
    $cols=explode(",",$groups[1]);
    
    $usbTot=count($cols);
    if($usbTot<4) die("Not enough LM on the usb");
    $color=imagecolorallocate($image, 255, 255, 0);
    $pointX0=$coordSW_x*256;
    $pointY0=$coordSW_y*256;
    $factor=$simSize/256;
    $pointX1=(integer)(($cols[0]-$pointX0)*$factor);
    $pointY1=(integer)($size_y-($cols[1]-$pointY0)*$factor);
    //echo "\nsize  $size_x   $size_y";
    $puntos=array(0,0,0,0,0,0,0,0);
    $grueso=3;
    $t = $grueso / 2 - 0.5;
    $k=0;
    $a=0;
    for($i=2;$i<$usbTot;$i+=2){
        $pointX2=(integer)(($cols[$i]-$pointX0)*$factor);
        $pointY2=(integer)($size_y-($cols[$i+1]-$pointY0)*$factor);
        //imageline($image,$pointX1,$pointY1,$pointX2,$pointY2,$color);
        
        if ($pointX1 == $pointX2 || $pointY1 == $pointY2) {
            imagefilledrectangle($image, round(min($pointX1, $pointX2) - $t), round(min($pointY1, $pointY2) - $t), 
                    round(max($pointX1, $pointX2) + $t), round(max($pointY1, $pointY2) + $t), $color);
        }else{        
            $k = ($pointY2 - $pointY1) / ($pointX2 - $pointX1);
            $a = $t / sqrt(1 + pow($k, 2));
            $puntos = array(
                round($pointX1 - (1+$k)*$a), round($pointY1 + (1-$k)*$a),
                round($pointX1 - (1-$k)*$a), round($pointY1 - (1+$k)*$a),
                round($pointX2 + (1+$k)*$a), round($pointY2 - (1-$k)*$a),
                round($pointX2 + (1-$k)*$a), round($pointY2 + (1+$k)*$a),
            );
            imagefilledpolygon($image, $puntos, 4, $color);
            imagepolygon($image, $puntos, 4, $color);
        }
        
        //echo "\n".$cols[$i]."   ".$cols[$i+1];
        //echo "\n$pointX1 $pointY1 $pointX2 $pointY2";
        $pointX1=$pointX2;
        $pointY1=$pointY2;
    }
    
    if($swMap==1){
        imagejpeg($image,"../map/".$file,100);
    }else{
        imagesavealpha($image, true);
        imagepng($image,"../map/".$file,0, PNG_NO_FILTER);
    }
    imagedestroy($image);
    echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file";
    //echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file".",";

    //echo "\ndist: $dist_x  $dist_y  $size_x   $size_y  $simSize";
    //echo "\n$simStart   $simEnd   $simStart_x   $simEnd_x   $simStart_y   $simEnd_y";
    
    
?>


























