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
    $baseWindDir=(integer)$cols[13];
    $baseWindSpeed=(integer)$cols[14];
    $baseCurrentSpeed=(integer)$cols[15];
    $baseCurrentDir=(integer)$cols[16];
    $baseWaveHeight=(integer)$cols[17];
    
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
        imagealphablending($image, true);
    }
    
    
    $simStart=($reqNum-1)*$reqSims;
    $simEnd=$simStart+$reqSims-1;
    if($simEnd>=$simTot) $simEnd=$simTot-1;
    $simStart_x=$simStart%$dist_x;
    $simEnd_x=$dist_x-1;
    $simStart_y=(integer)($simStart/$dist_x);
    $simEnd_y=(integer)($simEnd/$dist_x);
    
    $symbolSpace=70;    
    if($groups[1]!=""){
        $areas=explode("$$",$groups[1]);  //Area Variations

        $itemsTot=count($areas);
        $color=imagecolorallocate($image, 0, 255, 0);
        $pointX0=$coordSW_x*256;
        $pointY0=$coordSW_y*256;
        $factor=$simSize/256;
        $puntos=array(0,0,0,0,0,0,0,0);
        $areaparts=array("","");
        $symbols=imagecreatefrompng("images/glw_symbols.png");
        $symbol=array();
        $symbol_1=imagecreatetruecolor(35,19);
        imagealphablending($symbol_1, false);
        $symbol_2=imagecreatetruecolor(35,19);
        imagealphablending($symbol_2, false);
        $symbol_3=imagecreatetruecolor(35,19);
        imagealphablending($symbol_3, false);
        $symbol=array($symbol_1,$symbol_2,$symbol_3);
        $symbolRot=array($symbol_1,$symbol_2,$symbol_3);

        $datoprueba="\n".$itemsTot." / ";
        for($i=0;$i<$itemsTot;$i++){
            $areaparts=explode(":",$areas[$i]);
            $cols=explode(",",$areaparts[0]);  
            $pointX1=(integer)(($cols[2]-$pointX0)*$factor);
            $pointY1=(integer)($size_y-($cols[3]-$pointY0)*$factor);
            $pointX2=(integer)(($cols[5]-$pointX0+256)*$factor);       //+256 because we want the NE corner
            $pointY2=(integer)($size_y-($cols[6]-$pointY0+256)*$factor);  //+256 because we want the NE corner
            $puntos = array($pointX1,$pointY1,$pointX1,$pointY2,$pointX2,$pointY2,$pointX2,$pointY1);
            imagepolygon($image, $puntos, 4, $color);
            
            //symbols
            if($symbols){  
                $poligonSizeX=$pointX2-$pointX1;
                $poligonSizeY=$pointY1-$pointY2;
                $mode=0;   //horizontal  

                $cols=explode(",",$areaparts[1]);
                $nSymbols=0;
                if($cols[0]!="" || $cols[1]!=""){  //winddir and windspeed
                    imagecopy($symbol[$nSymbols],$symbols,0,0,0,0,35,19);
                    $winddir=$baseWindDir;
                    if($cols[0]!=""){
                        $winddir=(integer)$cols[0];
                    }
                    $windspeed=$baseWindSpeed;
                    if($cols[1]!=""){
                        $windspeed=(integer)$cols[1];
                    }
                    $winddir=$winddir+180;
                    if($winddir>360) $winddir=$winddir-360;
                    $symbolRot[$nSymbols] = imagerotate($symbol[$nSymbols], 360-$winddir+90, imageColorAllocateAlpha($symbol[$nSymbols], 0, 0, 0, 127));
                    imagealphablending($symbolRot[$nSymbols], false);
                    $nSymbols++;
                }
                if($cols[12]!="" || $baseCurrentSpeed!=0){ //currents
                    if($cols[12]!="" || $cols[13]!=""){
                        imagecopy($symbol[$nSymbols],$symbols,0,0,111,0,35,19);
                        $Currentspeed=$baseCurrenSpeed;
                        if($cols[12]!=""){
                            $Currentspeed=(integer)$cols[12];
                        }
                        $Currentdir=$baseCurrentDir;
                        if($cols[13]!=""){
                            $Currentdir=(integer)$cols[13];
                        }
                        $Currentdir=$Currentdir+180;
                        if($Currentdir>360) $Currentdir=$Currentdir-360;
                        $symbolRot[$nSymbols] = imagerotate($symbol[$nSymbols], 360-$Currentdir+90, imageColorAllocateAlpha($symbol[$nSymbols], 0, 0, 0, 127));
                        imagealphablending($symbolRot[$nSymbols], false);
                        $nSymbols++;
                    }
                }
                if($cols[5]!=""){  //waves
                    imagecopy($symbol[$nSymbols],$symbols,0,0,148,0,35,19);
                    //imagealphablending($symbol[$nSymbols], false);
                    imagecopy($symbolRot[$nSymbols],$symbol[$nSymbols],0,0,0,0,35,19);  
                    //imagealphablending($symbolRot[$nSymbols], false);
                    $nSymbols++;
                }
                
                $datoprueba.="\narea ".($i+1)."  $pointX1  $pointY1  $pointX2  $pointY2  $poligonSizeX   $poligonSizeY  //  ";
                if($nSymbols>2){ 
                    paintSymbols(3);
                    //imagecopy($image,$symbol[2],$pointX1+84,$pointY1-20,0,0,35,19);
                }else if($nSymbols>1){ 
                    paintSymbols(2);
                    /*
                    $symbolWidth0=imagesx($symbolRot[0]);
                    $symbolHeight0=imagesy($symbolRot[0]);
                    $symbolWidth1=imagesx($symbolRot[1]);
                    $symbolHeight1=imagesy($symbolRot[1]);
                    imagecopy($image,$symbolRot[0],$pointX1+2,$pointY1-20,0,0,$symbolWidth0,$symbolHeight0);
                    imagecopy($image,$symbolRot[1],$pointX1+47,$pointY1-20,0,0,$symbolWidth1,$symbolHeight1);
                     */
                }else if($nSymbols>0){  //1 symbol
                    paintSymbols(1);
                }
                //$datoprueba.=$areaparts[1]." ***   $nSymbols \n";
            }
        }
    }


    if($groups[2]!=""){
        $circles=explode("$$",$groups[2]);  //Circle Variations

        $itemsTot=count($circles);
        $color=imagecolorallocate($image, 0, 255, 0);
        $pointX0=$coordSW_x*256;
        $pointY0=$coordSW_y*256;
        $factor=$simSize/256;
        $circleparts=array("","");
        $diameter=0;
        for($i=0;$i<$itemsTot;$i++){
            $circleparts=explode(":",$circles[$i]);
            $cols=explode(",",$circleparts[0]);  
            $pointX1=(integer)(($cols[2]-$pointX0)*$factor);
            $pointY1=(integer)($size_y-($cols[3]-$pointY0)*$factor);
            $diameter=(integer)($cols[7]*$factor);

            imagearc($image, $pointX1, $pointY1, $diameter, $diameter,  0, 360, $color);
        }
    }

    if($swMap==1){
        imagejpeg($image,"../map/".$file,100);
    }else{
        imagesavealpha($image, true);
        imagepng($image,"../map/".$file,0, PNG_NO_FILTER);
    }
    imagedestroy($image);
    //echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file";
    echo "OK,$reqNum,$reqTot,$reqSims,$file,http://globalwind.net/map/$file";
    echo "\ndatosprueba: $datoprueba";
    
function paintSymbols($pNumSymbols)
{
    global $datoprueba;
    global $symbolRot;
    global $poligonSizeX;
    global $poligonSizeY;
    global $symbolSpace;
    global $pointX1;
    global $pointY1;
    global $image;
    $symbolWidth0=0;
    $symbolHeight0=0;
    $symbolWidth1=0;
    $symbolHeight1=0;
    $symbolWidth2=0;
    $symbolHeight2=0;
    $symbol_0=0;
    $symbol_1=0;
    $symbol_2=0;
    if($pNumSymbols==1){
        $symbol_0=0;
        $symbol_1=0;
        $symbol_2=0;
        $symbolWidth0=imagesx($symbolRot[0]);
        $symbolHeight0=imagesy($symbolRot[0]);
        $symbolWidth1=$symbolWidth0;
        $symbolHeight1=$symbolHeight0;
        $symbolWidth2=$symbolWidth0;
        $symbolHeight2=$symbolHeight0;
    }else if($pNumSymbols==2){
        $symbol_0=0;
        $symbol_1=1;
        $symbol_2=0;
        $symbolWidth0=imagesx($symbolRot[0]);
        $symbolHeight0=imagesy($symbolRot[0]);
        $symbolWidth1=imagesx($symbolRot[1]);
        $symbolHeight1=imagesy($symbolRot[1]);
        $symbolWidth2=$symbolWidth0;
        $symbolHeight2=$symbolHeight0;
        //imagecopy($image,$symbolRot[0],$pointX1+2,$pointY1-20,0,0,$symbolWidth0,$symbolHeight0);
        //imagecopy($image,$symbolRot[1],$pointX1+47,$pointY1-20,0,0,$symbolWidth1,$symbolHeight1);
    }
    $numSymbolsX=(integer)($poligonSizeX/$symbolSpace);  // symbols that fit in a rectangle along the x-axis
    if($numSymbolsX==0) $numSymbolsX=1;
    $spaceX=(integer)($poligonSizeX/$numSymbolsX);       // space that each symbol will occupy in x-axis
    $numSymbolsY=(integer)($poligonSizeY/$symbolSpace);  // symbols that fit in a rectangle along the y-axis
    if($numSymbolsY==0) $numSymbolsY=1;
    $spaceY=(integer)($poligonSizeY/$numSymbolsY);       // space that each symbol will occupy in y-axis
    //$datoprueba.=" ($symbolWidth0   $symbolHeight0) ";
    $nx=0;
    $ny=0;
    $nn=0;
    for($k=0;$k<$numSymbolsX;$k++){
        $datoprueba.="******************** $k ";
        $nn=$k%3;  //column
        $nx=$pointX1+$spaceX*$k+(integer)($spaceX/2-($symbolWidth0/2));
        if($nn==0){  //first column
            $datoprueba.="hola* $numSymbolsX   $numSymbolsY";
            if($numSymbolsX==1 && $numSymbolsY>1){
                if($numSymbolsY==2){
                    $ny=$pointY1-(integer)($poligonSizeY/4+$symbolHeight0/2);
                    imagecopy($image,$symbolRot[$symbol_0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
                    $ny=$pointY1-(integer)($poligonSizeY*3/4+$symbolHeight1/2);
                    imagecopy($image,$symbolRot[$symbol_1],$nx,$ny,0,0,$symbolWidth1,$symbolHeight1);
                }else{
                    $ny=$pointY1-(integer)($poligonSizeY/4+$symbolHeight0/2);
                    imagecopy($image,$symbolRot[$symbol_0],$nx-(integer)($poligonSizeX/4),$ny,0,0,$symbolWidth0,$symbolHeight0);
                    $ny=$pointY1-(integer)($poligonSizeY/2+$symbolHeight1/2);
                    imagecopy($image,$symbolRot[$symbol_1],$nx+(integer)($poligonSizeX/4),$ny,0,0,$symbolWidth1,$symbolHeight1);
                    $ny=$pointY1-(integer)($poligonSizeY*3/4+$symbolHeight2/2);
                    imagecopy($image,$symbolRot[$symbol_2],$nx,$ny,0,0,$symbolWidth2,$symbolHeight2);
                }
            }else if($numSymbolsX==1 && $numSymbolsY==1){
                if($pNumSymbols==1){
                    $nx=$pointX1+(integer)($poligonSizeX/2-$symbolWidth0/2);
                    $ny=$pointY1-(integer)($poligonSizeY/2+$symbolHeight0/2);
                    imagecopy($image,$symbolRot[0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
                }else if($pNumSymbols==2){
                    $nx=$pointX1+(integer)($poligonSizeX/4-$symbolWidth0/2);
                    $ny=$pointY1-(integer)($poligonSizeY/2+$symbolHeight0/2);
                    $datoprueba.="hola1 $nx  $ny  $poligonSizeX  $symbolWidth0";
                    imagecopy($image,$symbolRot[0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
                    $nx=$pointX1+(integer)($poligonSizeX*3/4-$symbolWidth1/2);
                    $ny=$pointY1-(integer)($poligonSizeY/2+$symbolHeight1/2);
                    imagecopy($image,$symbolRot[1],$nx,$ny,0,0,$symbolWidth1,$symbolHeight1);
                }else if($pNumSymbols==3){
                    
                }
            }else{
                if($pNumSymbols==1){
                    $ny=$pointY1-(integer)($poligonSizeY/2+$symbolHeight0/2);
                    imagecopy($image,$symbolRot[0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
                }
            }
        }else if($nn==1){  //second column
            if($numSymbolsX==2){
                $ny=$pointY1-(integer)($poligonSizeY/4+$symbolHeight/2);
                imagecopy($image,$symbolRot[$symbol_0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
                $ny=$pointY1-(integer)($poligonSizeY*3/4+$symbolHeight0/2);
                imagecopy($image,$symbolRot[$symbol_1],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
            }else if($numSymbolsX>2){
                $ny=$pointY1-(integer)($poligonSizeY/4+$symbolHeight0/2);
                imagecopy($image,$symbolRot[0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
            }
        }else if($nn==2){ //third column
            $ny=$pointY1-(integer)($poligonSizeY*3/4+$symbolHeight0/2);
            imagecopy($image,$symbolRot[0],$nx,$ny,0,0,$symbolWidth0,$symbolHeight0);
        }
    }    
}    
    
?>


























