<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
// Mind that some headers are not included because they're either useless or unreliable. X-Secondlife-Local-Position 
$headers    = apache_request_headers();
$objectgrid = $headers["X-Secondlife-Shard"];
$objectname = $headers["X-Secondlife-Object-Name"];
$objectkey  = $headers["X-Secondlife-Object-Key"];
$objectpos  = $headers["X-Secondlife-Local-Position"];
$ownerkey   = $headers["X-Secondlife-Owner-Key"];
$ownername  = $headers["X-Secondlife-Owner-Name"];
$regiondata = $headers["X-Secondlife-Region"];
$regiontmp  = explode ("(",$regiondata);            // cut cords off
$regionname = substr($regiontmp[0],0,-1);           // cut last space from simname
$regiontmp  = explode (")",$regiontmp[1]);
$regionpos  = $regiontmp[0];

$data       = file_get_contents("php://input");
$cols       = explode(",",$data);
$directorKey = $cols[0];
$windsetterUrl = $cols[1];
$idEvents=0;

require '../../glwdb.php';

$sql = "SELECT `id`, `directorKey`, `eventNum`, `server`, `systemMode`, `waterDepth`, `extra1`, `extra2`, 
            `sailMode`, `directorName`, `eventName`, `wndDir`, `wndSpeed`, `wndGusts`, `wndShifts`, 
            `wndPeriod`, `wavHeight`, `wavLength`, `wavSpeed`, `wavHeightVariance`, `wavLengthVariance`, 
            `wavEffects`, `crtDir`, `crtSpeed`, `wavesType`, `updBoatPos` FROM `glwEvents` 
       WHERE directorKey='".$directorKey."' ORDER BY updTime DESC";
$result = $conn->query($sql); 
$numRows=$result->num_rows;
if ($numRows > 0) {
    $s="";
    foreach($result as $field=>$value){
        $idEvents=$value['id'];
        $s= $value['eventNum'].",".$idEvents.",".$value['directorKey'].",".$value['directorName'].",".$value['systemMode']."##".
            $value['wndDir'].",".$value['wndSpeed'].",".$value['wndGusts'].",".$value['wndShifts'].",".$value['wndPeriod'].",".
            $value['wavSpeed'].",".$value['wavHeightVariance'].",".$value['wavLengthVariance'].",".$value['wavHeight'].",".
            $value['wavLength'].",".$value['wavEffects'].",".$value['crtDir'].",".$value['crtSpeed'].",".
            $value['sailMode'].",".$value['eventName'].",".$value['extra1'].",".$value['extra2'].",".
            $value['waterDepth'].",".$value['updBoatPos'].",".$value['wavesType'];
    }
    
    $sql = "SELECT `id`, `type`, `itemData`, `windData` FROM `glwVariations` 
       WHERE idEvents='".$idEvents."' ORDER BY type,id";
    $result = $conn->query($sql); 
    $varAreas="";
    $varCircles="";
    $numRows=$result->num_rows;
    if ($numRows > 0) {
        foreach($result as $field=>$value){
            if($value['type']==1){ 
                if($varAreas!="") $varAreas.="$$";
                $varAreas.=$value['itemData'].":".$value['windData'];
            }else if($value['type']==2){
                if($varCircles!="") $varCircles.="$$";
                $varCircles.=$value['itemData'].":".$value['windData'];
            }
        }
    }
    echo "OK0,".$s."##".$varAreas."##".$varCircles;
} else if ($numRows==0) {
    $conn->close();
    die("OK1No events found for this Director ");  //
} else {
    $conn->close();
    die("KORecovery Error: " . $sql . "<br>" . $conn->error);
}

if($idEvents>0){
    $sql="UPDATE glwEvents SET windsetterUrl='".$windsetterUrl."' WHERE id=".$idEvents;
    $conn->query($sql);
}
$conn->close();
?>


























